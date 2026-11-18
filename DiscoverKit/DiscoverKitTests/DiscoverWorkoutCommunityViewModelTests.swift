//
//  DiscoverWorkoutCommunityViewModelTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 18/11/2026.
//

import XCTest
@testable import DiscoverKit

@MainActor
final class DiscoverWorkoutCommunityViewModelTests: XCTestCase {

    func test_init_showsTheCardsCopyBeforeLoading() {
        let sut = makeSUT(initial: community(people: 4))

        XCTAssertEqual(sut.viewModel.shown, community(people: 4))
        XCTAssertTrue(sut.loader.receivedMessages.isEmpty)
    }

    func test_load_deliversTheFreshStatsForThisWorkout() async {
        let sut = makeSUT(initial: community(people: 4))
        sut.loader.result = .success(community(people: 9))

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.shown, community(people: 9))
        XCTAssertEqual(sut.loader.receivedMessages, [.community("w1")])
    }

    // The card's numbers are a little old, not wrong; blanking them for a
    // network blip would say less.
    func test_load_keepsWhatIsShownWhenTheReadFails() async {
        let sut = makeSUT(initial: community(people: 4))
        sut.loader.result = .failure(anyError)

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.shown, community(people: 4))
    }

    // A read that finds none means the workout has fallen below three people.
    func test_load_clearsTheStatsWhenTheCardNoLongerHasAny() async {
        let sut = makeSUT(initial: community(people: 4))
        sut.loader.result = .success(nil)

        await sut.viewModel.load()

        XCTAssertNil(sut.viewModel.shown)
    }

    // Under three people an average is someone's own sessions; the server
    // writes none, and a stray one must still never be drawn.
    func test_shown_isNilBelowThreePeople() {
        let sut = makeSUT(initial: community(people: 2))

        XCTAssertNil(sut.viewModel.shown)
    }

    // MARK: - Helpers

    private func makeSUT(
        initial: DiscoverWorkoutCommunity? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (viewModel: DiscoverWorkoutCommunityViewModel, loader: WorkoutCommunityLoaderSpy) {
        let loader = WorkoutCommunityLoaderSpy()
        let viewModel = DiscoverWorkoutCommunityViewModel(templateId: "w1", initial: initial, loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(viewModel, file: file, line: line)
        return (viewModel, loader)
    }

    private func community(people: Int) -> DiscoverWorkoutCommunity {
        DiscoverWorkoutCommunity(peopleCount: people, sessionCount: people * 2, averageDurationSeconds: 2700, averageRPE: 7)
    }
}

private let anyError = NSError(domain: "test", code: 0)
