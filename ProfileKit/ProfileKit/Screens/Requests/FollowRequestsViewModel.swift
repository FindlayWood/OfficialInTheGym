//
//  FollowRequestsViewModel.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import Combine
import Foundation

/// Requests to follow a private account (`PROFILE_PLAN.md` step 6), newest
/// first, each with Approve and Decline.
///
/// **Approving keeps the row and marks it "Approved"; declining removes it.**
/// An approval is a yes the user wants to see land, and the row is where they
/// were looking. A decline is a no that needs no record. Neither asks first:
/// both are what the user came to the screen to do, and a declined person can
/// simply ask again.
///
/// Both show at once and are put back if the write fails.
@MainActor
final class FollowRequestsViewModel: ObservableObject {

    struct Row: Identifiable, Equatable {
        let entry: FollowListEntry
        var summary: ProfileSummary?
        var isApproved = false

        var id: String { entry.followId }
        var userId: String { entry.userId }
    }

    enum LoadState: Equatable {
        case loading
        case loaded
        case failed
    }

    static let pageSize = 30

    @Published private(set) var loadState: LoadState = .loading
    @Published private(set) var rows: [Row] = []
    @Published private(set) var hasMore = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var errorMessage: String?

    private let requestsLoader: FollowRequestsLoader
    private let summaryLoader: ProfileSummaryLoader
    private let approver: FollowRequestApprover
    private let decliner: FollowerRemover

    init(
        requestsLoader: FollowRequestsLoader,
        summaryLoader: ProfileSummaryLoader,
        approver: FollowRequestApprover,
        decliner: FollowerRemover
    ) {
        self.requestsLoader = requestsLoader
        self.summaryLoader = summaryLoader
        self.approver = approver
        self.decliner = decliner
    }

    // MARK: - Load

    func load() async {
        if rows.isEmpty { loadState = .loading }
        do {
            rows = try await fetchPage(after: nil)
            loadState = .loaded
        } catch {
            print("❌ Follow requests failed: \(error)")
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
            print("❌ Follow requests next page failed: \(error)")
            errorMessage = "Couldn't load more. Check your connection and try again."
        }
    }

    private func fetchPage(after cursor: FollowListCursor?) async throws -> [Row] {
        let entries = try await requestsLoader.requests(after: cursor, limit: Self.pageSize)
        hasMore = entries.count == Self.pageSize
        let summaries: [String: ProfileSummary]
        do {
            summaries = try await summaryLoader.summaries(for: Set(entries.map(\.userId)))
        } catch {
            print("❌ Follow request names failed: \(error)")
            summaries = [:]
        }
        return entries.map { Row(entry: $0, summary: summaries[$0.userId]) }
    }

    // MARK: - Respond

    func approve(_ row: Row) async {
        guard let index = rows.firstIndex(where: { $0.id == row.id }), !rows[index].isApproved else { return }
        errorMessage = nil
        rows[index].isApproved = true
        do {
            try await approver.approve(row.userId)
        } catch {
            print("❌ Approve request failed: \(error)")
            if let current = rows.firstIndex(where: { $0.id == row.id }) {
                rows[current].isApproved = false
            }
            errorMessage = "Couldn't approve that request. Check your connection and try again."
        }
    }

    func decline(_ row: Row) async {
        guard let index = rows.firstIndex(where: { $0.id == row.id }) else { return }
        errorMessage = nil
        rows.remove(at: index)
        do {
            try await decliner.removeFollower(row.userId)
        } catch {
            print("❌ Decline request failed: \(error)")
            rows.insert(row, at: min(index, rows.count))
            errorMessage = "Couldn't decline that request. Check your connection and try again."
        }
    }
}
