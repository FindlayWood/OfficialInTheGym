//
//  FollowListViewModelTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import XCTest
@testable import ProfileKit

@MainActor
final class FollowListViewModelTests: XCTestCase {

    // MARK: - Load

    func test_load_deliversRowsWithNamesAndFollowStates() async {
        let sut = makeSUT(kind: .followers, pages: [.success([entry("a"), entry("b")])])
        sut.spy.summaries = ["a": summary("a")]
        sut.spy.statuses = ["a": .following, "b": .notFollowing]

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.loadState, .loaded)
        XCTAssertEqual(sut.viewModel.rows.map(\.userId), ["a", "b"])
        XCTAssertEqual(sut.viewModel.rows.map(\.summary), [summary("a"), nil])
        XCTAssertEqual(sut.viewModel.rows.map(\.status), [.following, .notFollowing])
    }

    // Your own following list is everyone you follow by definition; reading
    // the state of each row would be a request per row to learn nothing.
    func test_load_marksYourOwnFollowingListAsFollowingWithoutReading() async {
        let sut = makeSUT(kind: .following, pages: [.success([entry("a")])])

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.rows.first?.status, .following)
        XCTAssertFalse(sut.spy.receivedMessages.contains { if case .statuses = $0 { true } else { false } })
    }

    // A failed status read must not fail the list. The rows show, without
    // buttons, rather than an error over people the user can see are there.
    func test_load_keepsTheRowsWhenFollowStatesFail() async {
        let sut = makeSUT(kind: .followers, pages: [.success([entry("a")])])
        sut.spy.statusError = anyError

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.loadState, .loaded)
        XCTAssertNil(sut.viewModel.rows.first?.status)
    }

    func test_load_deliversFailedWhenTheListFails() async {
        let sut = makeSUT(pages: [.failure(anyError)])

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.loadState, .failed)
    }

    // MARK: - Paging

    func test_loadMore_resumesAfterTheLastRowsCursor() async {
        let firstPage = (0..<FollowListViewModel.pageSize).map { entry("u\($0)") }
        let sut = makeSUT(pages: [.success(firstPage), .success([entry("next")])])
        await sut.viewModel.load()
        XCTAssertTrue(sut.viewModel.hasMore)

        await sut.viewModel.loadMore()

        XCTAssertEqual(
            sut.spy.receivedMessages.last { if case .page = $0 { true } else { false } },
            .page(.followers, userId: "me", after: firstPage.last?.cursor, limit: FollowListViewModel.pageSize)
        )
        XCTAssertEqual(sut.viewModel.rows.count, FollowListViewModel.pageSize + 1)
        XCTAssertFalse(sut.viewModel.hasMore)
    }

    func test_loadMore_doesNothingAfterAShortPage() async {
        let sut = makeSUT(pages: [.success([entry("a")])])
        await sut.viewModel.load()

        await sut.viewModel.loadMore()

        XCTAssertEqual(sut.spy.receivedMessages.filter { if case .page = $0 { true } else { false } }.count, 1)
    }

    // MARK: - Follow

    // A private account turns a follow into a request; the row shows what the
    // server decided, not what was tapped.
    func test_toggleFollow_showsTheStatusTheWriterReturns() async {
        let sut = makeSUT(kind: .followers, pages: [.success([entry("a")])])
        sut.spy.statuses = ["a": .notFollowing]
        sut.spy.followResult = .requested
        await sut.viewModel.load()

        await sut.viewModel.toggleFollow(sut.viewModel.rows[0])

        XCTAssertEqual(sut.spy.receivedMessages.last, .follow("a"))
        XCTAssertEqual(sut.viewModel.rows.first?.status, .requested)
    }

    // The row stays after an unfollow, so tapping again undoes a mis-tap.
    func test_toggleFollow_unfollowsAndKeepsTheRow() async {
        let sut = makeSUT(kind: .following, pages: [.success([entry("a")])])
        await sut.viewModel.load()

        await sut.viewModel.toggleFollow(sut.viewModel.rows[0])

        XCTAssertEqual(sut.spy.receivedMessages.last, .unfollow("a"))
        XCTAssertEqual(sut.viewModel.rows.map(\.userId), ["a"])
        XCTAssertEqual(sut.viewModel.rows.first?.status, .notFollowing)
    }

    func test_toggleFollow_withdrawsARequest() async {
        let sut = makeSUT(kind: .followers, pages: [.success([entry("a")])])
        sut.spy.statuses = ["a": .requested]
        await sut.viewModel.load()

        await sut.viewModel.toggleFollow(sut.viewModel.rows[0])

        XCTAssertEqual(sut.spy.receivedMessages.last, .unfollow("a"))
    }

    func test_toggleFollow_putsTheStatusBackOnFailure() async {
        let sut = makeSUT(kind: .followers, pages: [.success([entry("a")])])
        sut.spy.statuses = ["a": .notFollowing]
        await sut.viewModel.load()
        sut.spy.writeError = anyError

        await sut.viewModel.toggleFollow(sut.viewModel.rows[0])

        XCTAssertEqual(sut.viewModel.rows.first?.status, .notFollowing)
        XCTAssertNotNil(sut.viewModel.errorMessage)
    }

    // MARK: - Remove follower

    func test_removeFollower_removesTheRow() async {
        let sut = makeSUT(kind: .followers, pages: [.success([entry("a"), entry("b")])])
        await sut.viewModel.load()

        await sut.viewModel.removeFollower(sut.viewModel.rows[0])

        XCTAssertEqual(sut.spy.receivedMessages.last, .removeFollower("a"))
        XCTAssertEqual(sut.viewModel.rows.map(\.userId), ["b"])
    }

    func test_removeFollower_putsTheRowBackInPlaceOnFailure() async {
        let sut = makeSUT(kind: .followers, pages: [.success([entry("a"), entry("b")])])
        await sut.viewModel.load()
        sut.spy.writeError = anyError

        await sut.viewModel.removeFollower(sut.viewModel.rows[0])

        XCTAssertEqual(sut.viewModel.rows.map(\.userId), ["a", "b"])
    }

    // Only your own followers are yours to remove.
    func test_removeFollower_isNotOfferedOnAFollowingListOrSomeoneElsesFollowers() {
        XCTAssertFalse(makeSUT(kind: .following).viewModel.canRemoveFollowers)
        XCTAssertFalse(makeSUT(kind: .followers, userId: "someoneElse").viewModel.canRemoveFollowers)
        XCTAssertTrue(makeSUT(kind: .followers).viewModel.canRemoveFollowers)
    }

    // MARK: - Helpers

    private func makeSUT(
        kind: FollowListKind = .followers,
        userId: String = "me",
        pages: [Result<[FollowListEntry], Error>] = []
    ) -> (viewModel: FollowListViewModel, spy: FollowServicesSpy) {
        let spy = FollowServicesSpy()
        spy.pages = pages
        let viewModel = FollowListViewModel(
            kind: kind,
            userId: userId,
            currentUserId: "me",
            listLoader: spy,
            summaryLoader: spy,
            statusLoader: spy,
            followWriter: spy,
            unfollower: spy,
            followerRemover: spy
        )
        return (viewModel, spy)
    }

    private func entry(_ userId: String) -> FollowListEntry {
        FollowListEntry(followId: "\(userId)_me", userId: userId, createdAt: fixedDate)
    }

    private func summary(_ userId: String) -> ProfileSummary {
        ProfileSummary(userId: userId, username: userId, displayName: "User \(userId)")
    }
}

private let fixedDate = Date(timeIntervalSince1970: 1_790_000_000)

private let anyError = NSError(domain: "test", code: 0)
