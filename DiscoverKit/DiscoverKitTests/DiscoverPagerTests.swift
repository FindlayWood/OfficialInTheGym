//
//  DiscoverPagerTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 28/09/2026.
//

import XCTest
@testable import DiscoverKit

@MainActor
final class DiscoverPagerTests: XCTestCase {

    func test_loadFirstPageIfNeeded_deliversFirstPage() async {
        let sut = makeSUT(total: 25, pageSize: 10)

        await sut.loadFirstPageIfNeeded()

        XCTAssertEqual(sut.cards.map(\.id), (0..<10).map(String.init))
        XCTAssertTrue(sut.hasMore)
    }

    func test_loadFirstPageIfNeeded_doesNothingOnceLoaded() async {
        var calls = 0
        let sut = DiscoverPager<Item>(pageSize: 10) { limit, last in
            calls += 1
            return items(25).previewPage(limit: limit, after: last)
        }

        await sut.loadFirstPageIfNeeded()
        await sut.loadFirstPageIfNeeded()

        XCTAssertEqual(calls, 1)
    }

    func test_loadMore_appendsNextPageWhenShowingLastCard() async {
        let sut = makeSUT(total: 25, pageSize: 10)
        await sut.loadFirstPageIfNeeded()

        await sut.loadMore(ifShowing: sut.cards[9])

        XCTAssertEqual(sut.cards.map(\.id), (0..<20).map(String.init))
    }

    // Every row calls loadMore as it appears. Only the last row may fetch, or
    // the first screenful of rows would each request the next page.
    func test_loadMore_doesNothingWhenShowingAnEarlierCard() async {
        let sut = makeSUT(total: 25, pageSize: 10)
        await sut.loadFirstPageIfNeeded()

        await sut.loadMore(ifShowing: sut.cards[3])

        XCTAssertEqual(sut.cards.count, 10)
    }

    // A page shorter than the page size is the end. Without this the pager
    // would keep asking for pages after the last one, forever.
    func test_loadMore_stopsAfterAShortPage() async {
        let sut = makeSUT(total: 25, pageSize: 10)
        await sut.loadFirstPageIfNeeded()
        await sut.loadMore(ifShowing: sut.cards[9])
        await sut.loadMore(ifShowing: sut.cards[19])

        XCTAssertEqual(sut.cards.count, 25)
        XCTAssertFalse(sut.hasMore)
    }

    func test_loadFirstPageIfNeeded_deliversFailureWithoutClearingCards() async {
        let sut = DiscoverPager<Item>(pageSize: 10) { _, _ in throw anyError }

        await sut.loadFirstPageIfNeeded()

        XCTAssertTrue(sut.didFail)
        XCTAssertTrue(sut.cards.isEmpty)
    }

    // A failed page must stay failed until the user retries — otherwise the
    // last row reappearing would hammer a failing request.
    func test_retry_loadsThePageThatFailed() async {
        var shouldFail = true
        let sut = DiscoverPager<Item>(pageSize: 10) { limit, last in
            if shouldFail { throw anyError }
            return items(25).previewPage(limit: limit, after: last)
        }
        await sut.loadFirstPageIfNeeded()

        shouldFail = false
        await sut.retry()

        XCTAssertFalse(sut.didFail)
        XCTAssertEqual(sut.cards.count, 10)
    }

    // MARK: - Helpers

    private func makeSUT(total: Int, pageSize: Int) -> DiscoverPager<Item> {
        DiscoverPager<Item>(pageSize: pageSize) { limit, last in
            items(total).previewPage(limit: limit, after: last)
        }
    }
}

private struct Item: Identifiable {
    let id: String
}

private func items(_ count: Int) -> [Item] {
    (0..<count).map { Item(id: String($0)) }
}

private let anyError = NSError(domain: "test", code: 0)
