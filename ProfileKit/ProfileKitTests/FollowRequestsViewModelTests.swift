//
//  FollowRequestsViewModelTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import XCTest
@testable import ProfileKit

@MainActor
final class FollowRequestsViewModelTests: XCTestCase {

    func test_load_deliversRequestsWithNames() async {
        let sut = makeSUT(pages: [.success([entry("a"), entry("b")])])
        sut.follows.summaries = ["b": ProfileSummary(userId: "b", username: "b", displayName: "Bee")]

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.loadState, .loaded)
        XCTAssertEqual(sut.viewModel.rows.map(\.userId), ["a", "b"])
        XCTAssertEqual(sut.viewModel.rows.last?.summary?.displayName, "Bee")
    }

    func test_load_deliversFailedWhenTheRequestsFail() async {
        let sut = makeSUT(pages: [.failure(anyError)])

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.loadState, .failed)
    }

    // An approval stays on screen as "Approved": it is the yes the user came to
    // give, and the row is where they were looking.
    func test_approve_marksTheRowApprovedAndKeepsIt() async {
        let sut = makeSUT(pages: [.success([entry("a")])])
        await sut.viewModel.load()

        await sut.viewModel.approve(sut.viewModel.rows[0])

        XCTAssertEqual(sut.privacy.receivedMessages.last, .approve("a"))
        XCTAssertEqual(sut.viewModel.rows.map(\.isApproved), [true])
    }

    func test_approve_doesNotApproveTwice() async {
        let sut = makeSUT(pages: [.success([entry("a")])])
        await sut.viewModel.load()
        await sut.viewModel.approve(sut.viewModel.rows[0])

        await sut.viewModel.approve(sut.viewModel.rows[0])

        XCTAssertEqual(sut.privacy.receivedMessages.filter { $0 == .approve("a") }.count, 1)
    }

    func test_approve_putsTheRequestBackOnFailure() async {
        let sut = makeSUT(pages: [.success([entry("a")])])
        await sut.viewModel.load()
        sut.privacy.writeError = anyError

        await sut.viewModel.approve(sut.viewModel.rows[0])

        XCTAssertEqual(sut.viewModel.rows.map(\.isApproved), [false])
        XCTAssertNotNil(sut.viewModel.errorMessage)
    }

    // Declining is the same delete as removing a follower: their pending
    // follow document goes.
    func test_decline_removesTheRowThroughTheFollowerRemover() async {
        let sut = makeSUT(pages: [.success([entry("a"), entry("b")])])
        await sut.viewModel.load()

        await sut.viewModel.decline(sut.viewModel.rows[0])

        XCTAssertEqual(sut.follows.receivedMessages.last, .removeFollower("a"))
        XCTAssertEqual(sut.viewModel.rows.map(\.userId), ["b"])
    }

    func test_decline_putsTheRowBackInPlaceOnFailure() async {
        let sut = makeSUT(pages: [.success([entry("a"), entry("b")])])
        await sut.viewModel.load()
        sut.follows.writeError = anyError

        await sut.viewModel.decline(sut.viewModel.rows[0])

        XCTAssertEqual(sut.viewModel.rows.map(\.userId), ["a", "b"])
    }

    func test_loadMore_resumesAfterTheLastRequest() async {
        let firstPage = (0..<FollowRequestsViewModel.pageSize).map { entry("u\($0)") }
        let sut = makeSUT(pages: [.success(firstPage), .success([entry("next")])])
        await sut.viewModel.load()

        await sut.viewModel.loadMore()

        XCTAssertEqual(sut.privacy.receivedMessages.last, .requests(after: firstPage.last?.cursor, limit: FollowRequestsViewModel.pageSize))
        XCTAssertEqual(sut.viewModel.rows.count, FollowRequestsViewModel.pageSize + 1)
    }

    // MARK: - Helpers

    private func makeSUT(
        pages: [Result<[FollowListEntry], Error>] = []
    ) -> (viewModel: FollowRequestsViewModel, privacy: PrivacyServicesSpy, follows: FollowServicesSpy) {
        let privacy = PrivacyServicesSpy()
        privacy.requestPages = pages
        let follows = FollowServicesSpy()
        let viewModel = FollowRequestsViewModel(
            requestsLoader: privacy,
            summaryLoader: follows,
            approver: privacy,
            decliner: follows
        )
        return (viewModel, privacy, follows)
    }

    private func entry(_ userId: String) -> FollowListEntry {
        FollowListEntry(followId: "\(userId)_me", userId: userId, createdAt: Date(timeIntervalSince1970: 1_790_000_000))
    }
}

private let anyError = NSError(domain: "test", code: 0)
