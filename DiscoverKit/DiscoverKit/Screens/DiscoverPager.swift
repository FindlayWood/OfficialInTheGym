//
//  DiscoverPager.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Combine
import Foundation

/// Drives a "see all" list: the first page on appear, the next when the last
/// row scrolls into view.
///
/// One pager for all three card types rather than three copies of the same
/// paging logic. The loader's `after:` cursor is the last card already shown,
/// so the pager needs nothing from a card beyond its identity.
///
/// A page shorter than `pageSize` means the end — no extra request to find out.
@MainActor
final class DiscoverPager<Card: Identifiable>: ObservableObject {

    @Published private(set) var cards: [Card] = []
    @Published private(set) var isLoading = false
    @Published private(set) var hasMore = true
    @Published private(set) var didFail = false

    let pageSize: Int
    private let loadPage: (Int, Card?) async throws -> [Card]

    init(pageSize: Int = 20, loadPage: @escaping (Int, Card?) async throws -> [Card]) {
        self.pageSize = pageSize
        self.loadPage = loadPage
    }

    func loadFirstPageIfNeeded() async {
        guard cards.isEmpty else { return }
        await loadNextPage()
    }

    /// Called as each row appears; only the last row triggers a fetch.
    func loadMore(ifShowing card: Card) async {
        guard card.id == cards.last?.id else { return }
        await loadNextPage()
    }

    /// Clears a failure and tries the page that failed again.
    func retry() async {
        didFail = false
        await loadNextPage()
    }

    private func loadNextPage() async {
        guard !isLoading, hasMore, !didFail else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let page = try await loadPage(pageSize, cards.last)
            cards.append(contentsOf: page)
            hasMore = page.count == pageSize
        } catch {
            print("❌ Discover page failed: \(error)")
            didFail = true
        }
    }
}
