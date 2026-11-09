//
//  MyDayScheduledItemsTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import Combine
import XCTest
@testable import MyDayKit

@MainActor
final class MyDayScheduledItemsTests: XCTestCase {

    func test_dueWorkouts_deliversNothingWithoutManagers() {
        let sut = MyDayScheduledItems.none

        XCTAssertEqual(sut.dueWorkouts(for: makeDay()), [])
    }

    func test_dueWorkouts_matchesSchedulesToTheLoadedLibrary() async throws {
        let (sut, schedules, library, _) = makeSUT()
        try await schedules.save(dueToday())
        library.state = .loaded([.fixture()])

        XCTAssertEqual(sut.dueWorkouts(for: makeDay()).map(\.template.title), ["Morning routine"])
    }

    func test_dueWorkouts_deliversNothingWhileTheLibraryIsLoading() async throws {
        let (sut, schedules, _, _) = makeSUT()
        try await schedules.save(dueToday())

        XCTAssertEqual(sut.dueWorkouts(for: makeDay()), [])
    }

    func test_scheduleChange_redrawsTheHomeScreen() async throws {
        let (sut, schedules, _, _) = makeSUT()
        var changes = 0
        let subscription = sut.objectWillChange.sink { changes += 1 }

        try await schedules.save(dueToday())

        XCTAssertGreaterThan(changes, 0)
        subscription.cancel()
    }

    func test_libraryChange_redrawsTheHomeScreen() {
        let (sut, _, library, _) = makeSUT()
        var changes = 0
        let subscription = sut.objectWillChange.sink { changes += 1 }

        library.state = .loaded([.fixture()])

        XCTAssertGreaterThan(changes, 0)
        subscription.cancel()
    }

    func test_loadIfNeeded_readsTheLibraryWhenAWorkoutIsDue() async throws {
        let (sut, schedules, library, templates) = makeSUT()
        try await schedules.save(dueToday())
        let loaded = expectation(description: "library loaded")
        // `.first`: the library publishes `.loaded` from local and again once merged with remote.
        let subscription = library.$state
            .first { state in
                if case .loaded = state { return true }
                return false
            }
            .sink { _ in loaded.fulfill() }

        await sut.loadIfNeeded(today: fixedDate)

        await fulfillment(of: [loaded], timeout: 1)
        XCTAssertGreaterThan(templates.fetchCount, 0)
        subscription.cancel()
    }

    // The library costs a Firestore read, which someone with nothing due should not pay for opening
    // MyDay.
    func test_loadIfNeeded_doesNotReadTheLibraryWhenNothingIsDue() async throws {
        let (sut, _, _, templates) = makeSUT()

        await sut.loadIfNeeded(today: fixedDate)
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(templates.fetchCount, 0)
    }

    // MARK: - Helpers

    private let fixedDate = Date(timeIntervalSince1970: 1_800_000_000)

    private func dueToday() -> Schedule {
        .fixture(recurrence: .once(day: ScheduleDay(fixedDate)))
    }

    private func makeDay() -> MyDayFullDayModel {
        MyDayFullDayModel(id: "day", date: fixedDate, exercises: [], workouts: [])
    }

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: MyDayScheduledItems, schedules: ScheduleManager, library: WorkoutLibraryManager, templates: WorkoutTemplateFetcherSpy) {
        let date = fixedDate
        let schedules = ScheduleManager(
            saver: ScheduleUploaderSpy(),
            local: ScheduleFetcherStub(),
            remote: ScheduleFetcherStub(),
            now: { date }
        )
        let templates = WorkoutTemplateFetcherSpy([.fixture()])
        let library = WorkoutLibraryManager(local: templates, remote: templates)
        let sut = MyDayScheduledItems(scheduleManager: schedules, libraryManager: library)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(schedules, file: file, line: line)
        trackForMemoryLeaks(library, file: file, line: line)
        return (sut, schedules, library, templates)
    }
}
