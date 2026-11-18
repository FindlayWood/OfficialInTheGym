//
//  ProfileWorkoutListViewModelTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 12/11/2026.
//

import XCTest
@testable import ProfileKit

@MainActor
final class ProfileWorkoutListViewModelTests: XCTestCase {

    func test_init_deliversLoadingBeforeTheFirstLoad() {
        let (sut, _) = makeSUT(kind: .library)

        guard case .loading = sut.state else { return XCTFail("Expected .loading, got \(sut.state)") }
    }

    func test_load_readsTheLibraryForAllWorkouts() async {
        let (sut, services) = makeSUT(kind: .library)
        services.libraryResults = [.success([.make(id: "a", isPublic: false)])]

        await sut.load()

        XCTAssertEqual(services.receivedMessages, [.allWorkouts])
        XCTAssertEqual(loadedIds(sut), ["a"])
    }

    func test_load_readsThatPersonsPublicWorkoutsForSeeAll() async {
        let (sut, services) = makeSUT(kind: .publicWorkouts(userId: "alex"))
        services.publicResults = [.success([.make(id: "a", createdBy: "alex")])]

        await sut.load()

        XCTAssertEqual(services.receivedMessages, [.publicWorkouts("alex", limit: ProfileWorkoutListViewModel.publicLimit)])
        XCTAssertEqual(loadedIds(sut), ["a"])
    }

    // A workout built in MyDay since the last visit has to be listed on the way back, which is why
    // the screen loads on every appearance.
    func test_load_deliversTheLatestLibraryOnEachLoad() async {
        let (sut, services) = makeSUT(kind: .library)
        services.libraryResults = [.success([.make(id: "a")]), .success([.make(id: "b"), .make(id: "a")])]
        await sut.load()

        await sut.load()

        XCTAssertEqual(loadedIds(sut), ["b", "a"])
    }

    func test_load_deliversFailedWhenTheFirstLoadFails() async {
        let (sut, services) = makeSUT(kind: .library)
        services.libraryResults = [.failure(anyError)]

        await sut.load()

        guard case .failed = sut.state else { return XCTFail("Expected .failed, got \(sut.state)") }
    }

    // Offline means stale, not broken: a refresh that fails must not blank a list on screen.
    func test_load_keepsTheShownListWhenARefreshFails() async {
        let (sut, services) = makeSUT(kind: .library)
        services.libraryResults = [.success([.make(id: "a")]), .failure(anyError)]
        await sut.load()

        await sut.load()

        XCTAssertEqual(loadedIds(sut), ["a"])
    }

    func test_load_recoversFromFailedOnRetry() async {
        let (sut, services) = makeSUT(kind: .library)
        services.libraryResults = [.failure(anyError), .success([.make(id: "a")])]
        await sut.load()

        await sut.load()

        XCTAssertEqual(loadedIds(sut), ["a"])
    }

    // MARK: - Helpers

    private let anyError = NSError(domain: "test", code: 0)

    private func loadedIds(_ sut: ProfileWorkoutListViewModel) -> [String]? {
        guard case .loaded(let workouts) = sut.state else { return nil }
        return workouts.map(\.workoutId)
    }

    private func makeSUT(
        kind: ProfileWorkoutListKind,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ProfileWorkoutListViewModel, services: WorkoutServicesSpy) {
        let services = WorkoutServicesSpy()
        let sut = ProfileWorkoutListViewModel(kind: kind, workoutsLoader: services, libraryLoader: services)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(services, file: file, line: line)
        return (sut, services)
    }
}
