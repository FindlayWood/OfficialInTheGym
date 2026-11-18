//
//  WorkoutHistoryViewModelTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 18/11/2026.
//

import XCTest
@testable import MyDayKit

@MainActor
final class WorkoutHistoryViewModelTests: XCTestCase {

    func test_init_startsLoadingAndAsksForNothing() {
        let (sut, loader) = makeSUT()

        XCTAssertEqual(sut.state, .loading)
        XCTAssertEqual(loader.receivedMessages, [])
    }

    func test_load_asksForThisWorkoutsSessions() async {
        let (sut, loader) = makeSUT(templateId: "legs")

        await sut.load()

        XCTAssertEqual(loader.receivedMessages, [.sessions(templateId: "legs")])
    }

    func test_load_deliversTheSummaryOfTheSessions() async {
        let (sut, loader) = makeSUT()
        let sessions: [CompletedWorkoutSession] = [.fixture(rpe: 7), .fixture(rpe: 9)]
        loader.results = [.success(sessions)]

        await sut.load()

        XCTAssertEqual(sut.state, .loaded(WorkoutHistorySummary(sessions: sessions)))
    }

    func test_load_deliversFailedWhenNothingHasLoaded() async {
        let (sut, loader) = makeSUT()
        loader.results = [.failure(anyNSError())]

        await sut.load()

        XCTAssertEqual(sut.state, .failed)
    }

    // The page is reopened often; a network blip on the second visit must not wipe numbers the
    // user has already seen.
    func test_load_keepsTheLoadedSummaryWhenALaterReadFails() async {
        let (sut, loader) = makeSUT()
        let sessions: [CompletedWorkoutSession] = [.fixture(rpe: 6)]
        loader.results = [.success(sessions), .failure(anyNSError())]

        await sut.load()
        await sut.load()

        XCTAssertEqual(sut.state, .loaded(WorkoutHistorySummary(sessions: sessions)))
    }

    // MARK: - Helpers

    private func makeSUT(
        templateId: String = "a",
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: WorkoutHistoryViewModel, loader: WorkoutHistoryLoaderSpy) {
        let loader = WorkoutHistoryLoaderSpy()
        let sut = WorkoutHistoryViewModel(templateId: templateId, loader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
}
