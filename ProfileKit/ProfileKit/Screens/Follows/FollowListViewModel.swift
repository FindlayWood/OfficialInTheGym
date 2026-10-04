//
//  FollowListViewModel.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import Combine
import Foundation

/// A followers or following list (`PROFILE_PLAN.md` step 5), paged newest
/// first, each row with a follow button.
///
/// **Rows are not removed when you unfollow from your following list.** The
/// button turns to "Follow" and the row stays until the list is next loaded, so
/// a mis-tap is undone by tapping again rather than by going to find the
/// person. Removing a *follower* does take the row away: it is the deliberate
/// action, behind a confirmation, and leaving the row there would read as
/// failed.
///
/// Every action shows at once and is put back if the write fails, as DISCOVER's
/// likes are. A follow can also come back `.requested` rather than
/// `.following`: the writer reports what the server decided, and the row shows
/// that, not what was tapped.
///
/// Names and follow states load per page in parallel with nothing on screen
/// depending on the order. A missing profile leaves its row nameless, and a
/// failed status read leaves the button off, rather than failing the page.
@MainActor
final class FollowListViewModel: ObservableObject {

    struct Row: Identifiable, Equatable {
        let entry: FollowListEntry
        var summary: ProfileSummary?
        /// Where the signed-in user stands toward this person. `nil` draws no
        /// button: it is the signed-in user, or the state could not be read.
        var status: FollowStatus?

        var id: String { entry.followId }
        var userId: String { entry.userId }
    }

    enum LoadState: Equatable {
        case loading
        case loaded
        case failed
    }

    static let pageSize = 30

    let kind: FollowListKind

    @Published private(set) var loadState: LoadState = .loading
    @Published private(set) var rows: [Row] = []
    @Published private(set) var hasMore = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var errorMessage: String?

    private let userId: String
    private let currentUserId: String
    private let listLoader: FollowListLoader
    private let summaryLoader: ProfileSummaryLoader
    private let statusLoader: FollowStatusLoader
    private let followWriter: FollowWriter
    private let unfollower: Unfollower
    private let followerRemover: FollowerRemover

    init(
        kind: FollowListKind,
        userId: String,
        currentUserId: String,
        listLoader: FollowListLoader,
        summaryLoader: ProfileSummaryLoader,
        statusLoader: FollowStatusLoader,
        followWriter: FollowWriter,
        unfollower: Unfollower,
        followerRemover: FollowerRemover
    ) {
        self.kind = kind
        self.userId = userId
        self.currentUserId = currentUserId
        self.listLoader = listLoader
        self.summaryLoader = summaryLoader
        self.statusLoader = statusLoader
        self.followWriter = followWriter
        self.unfollower = unfollower
        self.followerRemover = followerRemover
    }

    /// Only your own followers can be removed.
    var canRemoveFollowers: Bool {
        kind == .followers && userId == currentUserId
    }

    // MARK: - Load

    func load() async {
        if rows.isEmpty { loadState = .loading }
        do {
            let page = try await fetchPage(after: nil)
            rows = page
            loadState = .loaded
        } catch {
            print("❌ \(kind.title) failed: \(error)")
            if rows.isEmpty { loadState = .failed }
        }
    }

    func loadMore() async {
        guard hasMore, !isLoadingMore, let last = rows.last else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            let page = try await fetchPage(after: last.entry.cursor)
            let known = Set(rows.map(\.id))
            rows += page.filter { !known.contains($0.id) }
        } catch {
            print("❌ \(kind.title) next page failed: \(error)")
            errorMessage = "Couldn't load more. Check your connection and try again."
        }
    }

    private func fetchPage(after cursor: FollowListCursor?) async throws -> [Row] {
        let entries = try await listLoader.page(kind, of: userId, after: cursor, limit: Self.pageSize)
        hasMore = entries.count == Self.pageSize

        let ids = entries.map(\.userId)
        async let summaries = loadSummaries(for: ids)
        async let statuses = loadStatuses(for: ids)
        let (loadedSummaries, loadedStatuses) = await (summaries, statuses)

        return entries.map { entry in
            Row(
                entry: entry,
                summary: loadedSummaries[entry.userId],
                status: entry.userId == currentUserId ? nil : loadedStatuses[entry.userId]
            )
        }
    }

    private func loadSummaries(for ids: [String]) async -> [String: ProfileSummary] {
        do {
            return try await summaryLoader.summaries(for: Set(ids))
        } catch {
            print("❌ Follow list names failed: \(error)")
            return [:]
        }
    }

    /// Your own following list is everyone you follow, by definition, so it
    /// needs no read.
    private func loadStatuses(for ids: [String]) async -> [String: FollowStatus] {
        if kind == .following && userId == currentUserId {
            return Dictionary(uniqueKeysWithValues: ids.map { ($0, .following) })
        }
        do {
            return try await statusLoader.statuses(toward: ids)
        } catch {
            print("❌ Follow states failed: \(error)")
            return [:]
        }
    }

    // MARK: - Actions

    func toggleFollow(_ row: Row) async {
        guard let status = row.status else { return }
        errorMessage = nil
        switch status {
        case .notFollowing:
            setStatus(.following, for: row.id)
            do {
                let result = try await followWriter.follow(row.userId)
                setStatus(result, for: row.id)
            } catch {
                print("❌ Follow failed: \(error)")
                setStatus(status, for: row.id)
                errorMessage = "Couldn't follow. Check your connection and try again."
            }
        case .following, .requested:
            setStatus(.notFollowing, for: row.id)
            do {
                try await unfollower.unfollow(row.userId)
            } catch {
                print("❌ Unfollow failed: \(error)")
                setStatus(status, for: row.id)
                errorMessage = "Couldn't unfollow. Check your connection and try again."
            }
        }
    }

    func removeFollower(_ row: Row) async {
        guard canRemoveFollowers, let index = rows.firstIndex(where: { $0.id == row.id }) else { return }
        errorMessage = nil
        rows.remove(at: index)
        do {
            try await followerRemover.removeFollower(row.userId)
        } catch {
            print("❌ Remove follower failed: \(error)")
            rows.insert(row, at: min(index, rows.count))
            errorMessage = "Couldn't remove that follower. Check your connection and try again."
        }
    }

    private func setStatus(_ status: FollowStatus, for rowId: String) {
        guard let index = rows.firstIndex(where: { $0.id == rowId }) else { return }
        rows[index].status = status
    }
}
