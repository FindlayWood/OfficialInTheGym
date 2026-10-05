//
//  DiscoverSearchViewModelTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 05/10/2026.
//

import XCTest
@testable import DiscoverKit

@MainActor
final class DiscoverSearchViewModelTests: XCTestCase {

    // People type usernames the way they see them written.
    func test_normalized_trimsLowercasesAndDropsALeadingAt() {
        XCTAssertEqual(DiscoverSearchQuery.normalized("  @Alex "), "alex")
        XCTAssertEqual(DiscoverSearchQuery.normalized("Back Squat"), "back squat")
    }

    func test_search_deliversEveryKind() async {
        let sut = makeSUT()
        sut.spy.people = ["pu": [person("pulkit")]]
        sut.spy.workouts = ["pu": [workout("Push Day")]]
        sut.spy.exercises = ["pu": [exercise("Pull Up")]]
        sut.viewModel.query = "Pu"

        await sut.viewModel.search("pu")

        XCTAssertEqual(sut.viewModel.people, .loaded([person("pulkit")]))
        XCTAssertEqual(sut.viewModel.workouts, .loaded([workout("Push Day")]))
        XCTAssertEqual(sut.viewModel.exercises, .loaded([exercise("Pull Up")]))
    }

    // The three are separate queries; one failing must not blank the others,
    // or a network blip on workouts would hide the person the user was after.
    func test_search_failsOnlyTheKindWhoseLoaderFailed() async {
        let sut = makeSUT()
        sut.spy.people = ["pu": [person("pulkit")]]
        sut.spy.workoutsError = anyError
        sut.viewModel.query = "pu"

        await sut.viewModel.search("pu")

        XCTAssertEqual(sut.viewModel.people, .loaded([person("pulkit")]))
        XCTAssertEqual(sut.viewModel.workouts, .failed)
        XCTAssertEqual(sut.viewModel.exercises, .loaded([]))
    }

    // DISCOVER never opens your own profile, so your own row would lead nowhere.
    func test_search_leavesTheCurrentUserOutOfPeople() async {
        let sut = makeSUT(currentUserId: "me")
        sut.spy.people = ["m": [person("me"), person("mia")]]
        sut.viewModel.query = "m"

        await sut.viewModel.search("m")

        XCTAssertEqual(sut.viewModel.people, .loaded([person("mia")]))
    }

    // A slow search for "a" finishing after the user has typed "alex" must not
    // replace the results for what is now in the field.
    func test_search_ignoresResultsForAQueryNoLongerInTheField() async {
        let sut = makeSUT()
        sut.spy.people = ["a": [person("anna")]]
        sut.viewModel.query = "alex"

        await sut.viewModel.search("a")

        XCTAssertNotEqual(sut.viewModel.people, .loaded([person("anna")]))
    }

    func test_retryWorkouts_searchesOnlyWorkoutsAgain() async {
        let sut = makeSUT()
        sut.spy.workoutsError = anyError
        sut.viewModel.query = "pu"
        await sut.viewModel.search("pu")

        sut.spy.workoutsError = nil
        sut.spy.workouts = ["pu": [workout("Push Day")]]
        await sut.viewModel.retryWorkouts()

        XCTAssertEqual(sut.viewModel.workouts, .loaded([workout("Push Day")]))
        XCTAssertEqual(sut.spy.receivedMessages.filter { if case .people = $0 { true } else { false } }.count, 1)
    }

    func test_query_whitespaceOnlyIsIdle() {
        let sut = makeSUT()
        sut.viewModel.query = "al"
        XCTAssertFalse(sut.viewModel.isIdle)

        sut.viewModel.query = "  "

        XCTAssertTrue(sut.viewModel.isIdle)
    }

    // One query per pause, not one per letter, and only the last one counts.
    func test_query_debouncesToTheLastValue() async throws {
        let sut = makeSUT(debounce: .milliseconds(20))
        sut.spy.exercises = ["back": [exercise("Back Squat")]]

        sut.viewModel.query = "b"
        sut.viewModel.query = "ba"
        sut.viewModel.query = "Back"
        try await Task.sleep(for: .milliseconds(150))

        let limit = DiscoverSearchViewModel.limit
        XCTAssertEqual(Set(sut.spy.receivedMessages), [
            .people("back", limit: limit),
            .workouts("back", limit: limit),
            .exercises("back", limit: limit)
        ])
        XCTAssertEqual(sut.viewModel.exercises, .loaded([exercise("Back Squat")]))
    }

    // MARK: - Helpers

    private func makeSUT(
        currentUserId: String = "current",
        debounce: Duration = .seconds(60)
    ) -> (viewModel: DiscoverSearchViewModel, spy: SearchLoaderSpy) {
        let spy = SearchLoaderSpy()
        let viewModel = DiscoverSearchViewModel(
            peopleLoader: spy,
            workoutLoader: spy,
            exerciseLoader: spy,
            currentUserId: currentUserId,
            debounce: debounce
        )
        return (viewModel, spy)
    }

    private func person(_ username: String) -> DiscoverUserProfile {
        DiscoverUserProfile(userId: username, username: username, displayName: username.capitalized)
    }

    private func workout(_ title: String) -> DiscoverWorkoutCard {
        DiscoverWorkoutCard(templateId: title, title: title, createdBy: "author", exerciseCount: 4, createdAt: nil, isPublic: true)
    }

    private func exercise(_ name: String) -> DiscoverExerciseCard {
        DiscoverExerciseCard(exerciseId: name, name: name, category: nil)
    }
}

private let anyError = NSError(domain: "test", code: 0)
