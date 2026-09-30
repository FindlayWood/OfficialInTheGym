//
//  DiscoverCommentsViewModel.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Combine
import Foundation

/// The comments on one subject: paging, replies, likes, posting and removing.
///
/// **Every action shows before the server confirms it** and is put back if
/// the write fails — a like, a post, a removal. The counts beside them are
/// recounted by Cloud Functions seconds later, and a comment screen that
/// waits for that reads as broken.
///
/// Authors are resolved to profiles here, in batches, as comments arrive —
/// never stored on the comment. `attemptedProfileIds` is what lets a row tell
/// "not loaded yet" (draw nothing) from "no such user" (draw "Deleted user").
@MainActor
final class DiscoverCommentsViewModel: ObservableObject {

    @Published private(set) var threads: [DiscoverCommentThread] = []
    @Published private(set) var profiles: [String: DiscoverUserProfile] = [:]
    @Published private(set) var likedCommentIds: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var hasMore = true
    @Published private(set) var didFailToLoad = false
    @Published private(set) var isPosting = false
    @Published private(set) var actionError: String?
    @Published var draft = ""
    @Published var replyingTo: DiscoverComment?

    static let pageSize = 20
    /// Must match the security rules' limit on `text`.
    static let maxLength = 500

    let subject: DiscoverSubject
    let currentUserId: String

    private var attemptedProfileIds: Set<String> = []

    private let commentLoader: CommentLoader
    private let replyLoader: ReplyLoader
    private let commentWriter: CommentWriter
    private let commentRemover: CommentRemover
    private let likeLoader: LikeLoader
    private let likeWriter: LikeWriter
    private let profileLoader: UserProfileLoader

    init(
        subject: DiscoverSubject,
        currentUserId: String,
        commentLoader: CommentLoader,
        replyLoader: ReplyLoader,
        commentWriter: CommentWriter,
        commentRemover: CommentRemover,
        likeLoader: LikeLoader,
        likeWriter: LikeWriter,
        profileLoader: UserProfileLoader
    ) {
        self.subject = subject
        self.currentUserId = currentUserId
        self.commentLoader = commentLoader
        self.replyLoader = replyLoader
        self.commentWriter = commentWriter
        self.commentRemover = commentRemover
        self.likeLoader = likeLoader
        self.likeWriter = likeWriter
        self.profileLoader = profileLoader
    }

    // MARK: - Loading

    func loadFirstPageIfNeeded() async {
        guard threads.isEmpty else { return }
        await loadNextPage()
    }

    func loadMore(ifShowing thread: DiscoverCommentThread) async {
        guard thread.id == threads.last?.id else { return }
        await loadNextPage()
    }

    func retry() async {
        didFailToLoad = false
        await loadNextPage()
    }

    private func loadNextPage() async {
        guard !isLoading, hasMore, !didFailToLoad else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let page = try await commentLoader.topLevelComments(
                on: subject, limit: Self.pageSize, after: threads.last?.comment
            )
            threads.append(contentsOf: page.map { DiscoverCommentThread(comment: $0) })
            hasMore = page.count == Self.pageSize
            await resolve(page)
        } catch {
            print("❌ Comments failed: \(error)")
            didFailToLoad = true
        }
    }

    func toggleReplies(_ thread: DiscoverCommentThread) async {
        guard let index = index(of: thread.id) else { return }
        if threads[index].isExpanded {
            threads[index].isExpanded = false
            return
        }
        threads[index].isExpanded = true
        guard threads[index].replies.isEmpty else { return }

        threads[index].isLoadingReplies = true
        do {
            let replies = try await replyLoader.replies(to: thread.id, on: subject)
            if let index = self.index(of: thread.id) {
                threads[index].replies = replies
                threads[index].isLoadingReplies = false
            }
            await resolve(replies)
        } catch {
            print("❌ Replies failed: \(error)")
            if let index = self.index(of: thread.id) {
                threads[index].isLoadingReplies = false
                threads[index].isExpanded = false
            }
            actionError = "Couldn't load replies."
        }
    }

    // MARK: - Display

    enum AuthorName: Equatable {
        case loading
        case deleted
        case name(String, initial: String)
    }

    func author(of comment: DiscoverComment) -> AuthorName {
        guard let authorId = comment.authorId else { return .deleted }
        if let profile = profiles[authorId] {
            return .name(profile.name, initial: profile.initial)
        }
        return attemptedProfileIds.contains(authorId) ? .deleted : .loading
    }

    func canRemove(_ comment: DiscoverComment) -> Bool {
        comment.authorId == currentUserId && !comment.isRemoved
    }

    var canPost: Bool {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        return !text.isEmpty && text.count <= Self.maxLength && !isPosting
    }

    // MARK: - Posting

    func post() async {
        guard canPost else { return }
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        let parent = replyingTo
        isPosting = true
        actionError = nil
        defer { isPosting = false }

        do {
            let comment = try await commentWriter.postComment(text, replyingTo: parent?.id, on: subject)
            draft = ""
            replyingTo = nil
            if let parent, let index = index(of: parent.id) {
                threads[index].replies.append(comment)
                threads[index].isExpanded = true
                threads[index].comment.replyCount = (threads[index].comment.replyCount ?? 0) + 1
            } else {
                threads.insert(DiscoverCommentThread(comment: comment), at: 0)
            }
            await resolve([comment])
        } catch {
            print("❌ Post failed: \(error)")
            actionError = "Couldn't post your comment."
        }
    }

    // MARK: - Removing

    func remove(_ comment: DiscoverComment) async {
        guard canRemove(comment) else { return }
        let snapshot = threads
        update(comment.id) { $0.status = "removed"; $0.text = "" }
        if let parentId = comment.parentId, let index = index(of: parentId) {
            threads[index].comment.replyCount = max(0, (threads[index].comment.replyCount ?? 1) - 1)
        }

        do {
            try await commentRemover.removeComment(comment.id, on: subject)
        } catch {
            print("❌ Remove failed: \(error)")
            threads = snapshot
            actionError = "Couldn't delete your comment."
        }
    }

    // MARK: - Liking

    func isLiked(_ comment: DiscoverComment) -> Bool {
        likedCommentIds.contains(comment.id)
    }

    func toggleLike(_ comment: DiscoverComment) async {
        guard !comment.isRemoved else { return }
        let liked = !isLiked(comment)
        setLikeLocally(liked, on: comment.id)

        do {
            try await likeWriter.setLiked(liked, for: .comment(commentId: comment.id, subject: subject))
        } catch {
            print("❌ Like failed: \(error)")
            setLikeLocally(!liked, on: comment.id)
            actionError = "Couldn't save your like."
        }
    }

    private func setLikeLocally(_ liked: Bool, on commentId: String) {
        if liked {
            likedCommentIds.insert(commentId)
        } else {
            likedCommentIds.remove(commentId)
        }
        update(commentId) { $0.likeCount = max(0, ($0.likeCount ?? 0) + (liked ? 1 : -1)) }
    }

    // MARK: - Helpers

    /// Loads the profiles and like state for newly arrived comments. Neither
    /// failing is worth an error on screen — rows fall back to a blank name
    /// and an unfilled heart.
    private func resolve(_ comments: [DiscoverComment]) async {
        let authorIds = Set(comments.compactMap(\.authorId)).subtracting(attemptedProfileIds)
        let targets = comments.map { DiscoverLikeTarget.comment(commentId: $0.id, subject: subject) }

        async let loadedProfiles = try? profileLoader.profiles(for: authorIds)
        async let loadedLikes = try? likeLoader.likedTargets(among: targets)
        let (found, likes) = await (loadedProfiles, loadedLikes)

        if let found {
            profiles.merge(found) { _, new in new }
            attemptedProfileIds.formUnion(authorIds)
        }
        for case let .comment(commentId, _) in likes ?? [] {
            likedCommentIds.insert(commentId)
        }
    }

    private func index(of threadId: String) -> Int? {
        threads.firstIndex { $0.id == threadId }
    }

    /// Applies `change` to a comment wherever it sits — a thread's top-level
    /// comment or one of its replies.
    private func update(_ commentId: String, _ change: (inout DiscoverComment) -> Void) {
        for index in threads.indices {
            if threads[index].comment.id == commentId {
                change(&threads[index].comment)
                return
            }
            if let replyIndex = threads[index].replies.firstIndex(where: { $0.id == commentId }) {
                change(&threads[index].replies[replyIndex])
                return
            }
        }
    }
}
