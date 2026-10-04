//
//  UserSearchViewModelTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import XCTest
@testable import ProfileKit

@MainActor
final class UserSearchViewModelTests: XCTestCase {

    // People type usernames the way they see them written.
    func test_normalized_trimsLowercasesAndDropsALeadingAt() {
        XCTAssertEqual(UserSearchViewModel.normalized("  @Alex "), "alex")
        XCTAssertEqual(UserSearchViewModel.normalized("Sam Reid"), "sam reid")
    }

    func test_search_deliversResults() async {
        let sut = makeSUT()
        sut.spy.searchResults = ["alex": [summary("alex")]]
        sut.viewModel.query = "alex"

        await sut.viewModel.search("alex")

        XCTAssertEqual(sut.viewModel.state, .results([summary("alex")]))
    }

    func test_search_deliversFailedOnError() async {
        let sut = makeSUT()
        sut.spy.searchError = anyError
        sut.viewModel.query = "alex"

        await sut.viewModel.search("alex")

        XCTAssertEqual(sut.viewModel.state, .failed)
    }

    // A slow search for "a" finishing after the user has typed "alex" must not
    // replace the results for what is now in the field.
    func test_search_ignoresResultsForAQueryNoLongerInTheField() async {
        let sut = makeSUT()
        sut.spy.searchResults = ["a": [summary("anna")]]
        sut.viewModel.query = "alex"

        await sut.viewModel.search("a")

        XCTAssertNotEqual(sut.viewModel.state, .results([summary("anna")]))
    }

    func test_query_clearedReturnsToIdle() {
        let sut = makeSUT()
        sut.viewModel.query = "al"

        sut.viewModel.query = "  "

        XCTAssertEqual(sut.viewModel.state, .idle)
    }

    // One query per pause, not one per letter, and only the last one counts.
    func test_query_debouncesToTheLastValue() async throws {
        let sut = makeSUT(debounce: .milliseconds(20))
        sut.spy.searchResults = ["alex": [summary("alex")]]

        sut.viewModel.query = "a"
        sut.viewModel.query = "al"
        sut.viewModel.query = "alex"
        try await Task.sleep(for: .milliseconds(150))

        XCTAssertEqual(sut.spy.receivedMessages, [.search("alex", limit: UserSearchViewModel.limit)])
        XCTAssertEqual(sut.viewModel.state, .results([summary("alex")]))
    }

    // MARK: - Helpers

    private func makeSUT(debounce: Duration = .seconds(60)) -> (viewModel: UserSearchViewModel, spy: PublicProfileServicesSpy) {
        let spy = PublicProfileServicesSpy()
        return (UserSearchViewModel(loader: spy, debounce: debounce), spy)
    }

    private func summary(_ username: String) -> ProfileSummary {
        ProfileSummary(userId: username, username: username, displayName: username.capitalized)
    }
}

private let anyError = NSError(domain: "test", code: 0)
