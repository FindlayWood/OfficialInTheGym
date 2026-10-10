//
//  CatalogueExerciseSearchLoaderTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import DiscoverKit

final class CatalogueExerciseSearchLoaderTests: XCTestCase {

    func test_exercises_deliversMatchesFromTheCatalogue() async throws {
        let (sut, spy) = makeSUT()
        spy.results = [.success([card("Back Squat"), card("Deadlift")])]

        let results = try await sut.exercises(matching: "squat", limit: 10)

        XCTAssertEqual(results.map(\.name), ["Back Squat"])
    }

    // One read of the catalogue per session, not one per keystroke.
    func test_exercises_loadsTheCatalogueOnceAcrossSearches() async throws {
        let (sut, spy) = makeSUT()
        spy.results = [.success([card("Back Squat")])]

        _ = try await sut.exercises(matching: "b", limit: 10)
        _ = try await sut.exercises(matching: "ba", limit: 10)

        XCTAssertEqual(spy.receivedMessages, [.allExercises])
    }

    // A failure kept would leave exercise search broken until relaunch.
    func test_exercises_triesTheCatalogueAgainAfterAFailedLoad() async throws {
        let (sut, spy) = makeSUT()
        spy.results = [.failure(anyError), .success([card("Back Squat")])]

        _ = try? await sut.exercises(matching: "back", limit: 10)
        let results = try await sut.exercises(matching: "back", limit: 10)

        XCTAssertEqual(results.map(\.name), ["Back Squat"])
        XCTAssertEqual(spy.receivedMessages, [.allExercises, .allExercises])
    }

    // MARK: - Helpers

    private func makeSUT() -> (CatalogueExerciseSearchLoader, ExerciseCatalogueLoaderSpy) {
        let spy = ExerciseCatalogueLoaderSpy()
        return (CatalogueExerciseSearchLoader(catalogue: spy), spy)
    }

    private func card(_ name: String) -> DiscoverExerciseCard {
        DiscoverExerciseCard(exerciseId: name, name: name, category: nil)
    }
}

private let anyError = NSError(domain: "test", code: 0)
