//
//  DiscoverCommentsScreen.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// Every comment on one exercise, workout or clip, newest first, each with its
/// replies one tap away, and the composer pinned to the bottom.
///
/// Same `darkColor` page and `SectionContainer` card as every other DISCOVER
/// screen. The composer sits outside the scroll view so the keyboard lifts it
/// rather than covering it.
struct DiscoverCommentsScreen: View {

    @ObservedObject var viewModel: DiscoverCommentsViewModel
    @ObservedObject var moderation: DiscoverModerationStore
    var onOpenBlockedUsers: () -> Void = {}

    @State private var reportRequest: DiscoverReportRequest?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                SectionContainer {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(shownThreads) { thread in
                            threadView(thread)
                                .task { await viewModel.loadMore(ifShowing: thread) }
                            if thread.id != shownThreads.last?.id {
                                Divider()
                            }
                        }
                        footer
                    }
                    .padding(.horizontal, 16)
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)

            if let error = viewModel.actionError {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .padding(.vertical, 6)
            }

            DiscoverCommentComposer(viewModel: viewModel)
        }
        .background {
            Color.darkColor.ignoresSafeArea()
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Blocked users", systemImage: "hand.raised", action: onOpenBlockedUsers)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $reportRequest) { request in
            DiscoverReportSheet(target: request.target, moderation: moderation)
                .presentationDetents([.medium])
        }
        .task {
            async let comments: Void = viewModel.loadFirstPageIfNeeded()
            async let moderationState: Void = moderation.loadIfNeeded()
            _ = await (comments, moderationState)
        }
    }

    /// Threads worth drawing: not removed-and-empty, and nothing this user has
    /// blocked or reported.
    private var shownThreads: [DiscoverCommentThread] {
        viewModel.threads.filter { $0.isShown && !moderation.hides($0.comment, on: viewModel.subject) }
    }

    private func shownReplies(of thread: DiscoverCommentThread) -> [DiscoverComment] {
        thread.visibleReplies.filter { !moderation.hides($0, on: viewModel.subject) }
    }

    @ViewBuilder
    private func threadView(_ thread: DiscoverCommentThread) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            row(thread.comment, canReply: true)

            let replyCount = thread.comment.replyCount ?? thread.visibleReplies.count
            if replyCount > 0 {
                Button {
                    Task { await viewModel.toggleReplies(thread) }
                } label: {
                    HStack(spacing: 6) {
                        Rectangle().fill(Color(.separator)).frame(width: 18, height: 1)
                        Text(thread.isExpanded ? "Hide replies" : (replyCount == 1 ? "View 1 reply" : "View \(replyCount) replies"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                        if thread.isLoadingReplies {
                            ProgressView().scaleEffect(0.7)
                        }
                    }
                    .padding(.leading, 42)
                    .padding(.bottom, 8)
                }
                .buttonStyle(.plain)
            }

            if thread.isExpanded {
                ForEach(shownReplies(of: thread)) { reply in
                    row(reply, canReply: false)
                        .padding(.leading, 42)
                }
            }
        }
    }

    private func row(_ comment: DiscoverComment, canReply: Bool) -> some View {
        DiscoverCommentRow(
            comment: comment,
            author: viewModel.author(of: comment),
            isLiked: viewModel.isLiked(comment),
            canRemove: viewModel.canRemove(comment),
            onLike: { Task { await viewModel.toggleLike(comment) } },
            onReply: canReply ? { viewModel.replyingTo = comment } : nil,
            onRemove: { Task { await viewModel.remove(comment) } },
            onReport: isOthers(comment) ? {
                reportRequest = DiscoverReportRequest(target: .comment(commentId: comment.id, subject: viewModel.subject))
            } : nil,
            onBlock: isOthers(comment) ? {
                if let authorId = comment.authorId {
                    Task { await moderation.setBlocked(true, userId: authorId) }
                }
            } : nil
        )
    }

    private func isOthers(_ comment: DiscoverComment) -> Bool {
        guard let authorId = comment.authorId else { return false }
        return authorId != viewModel.currentUserId && !comment.isRemoved
    }

    @ViewBuilder
    private var footer: some View {
        if viewModel.didFailToLoad {
            DiscoverSectionMessage(message: "Couldn't load comments") {
                Task { await viewModel.retry() }
            }
        } else if viewModel.isLoading {
            ProgressView().frame(maxWidth: .infinity).padding(.vertical, 16)
        } else if shownThreads.isEmpty {
            DiscoverSectionMessage(message: "No comments yet — be the first.")
        }
    }
}

#Preview {
    NavigationStack {
        DiscoverCommentsScreen(
            viewModel: DiscoverCommentsViewModel(
                subject: .workout(id: "w1"),
                currentUserId: "u1",
                commentLoader: PreviewCommentLoader(),
                replyLoader: PreviewCommentLoader(),
                commentWriter: PreviewCommentWriter(),
                commentRemover: PreviewCommentWriter(),
                likeLoader: PreviewLikeLoader(),
                likeWriter: PreviewCommentWriter(),
                profileLoader: PreviewUserProfileLoader()
            ),
            moderation: PreviewModeration.store()
        )
    }
}
