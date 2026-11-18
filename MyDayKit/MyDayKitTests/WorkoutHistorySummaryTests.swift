//
//  WorkoutHistorySummaryTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 18/11/2026.
//

import XCTest
@testable import MyDayKit

final class WorkoutHistorySummaryTests: XCTestCase {

    func test_init_deliversNothingDoneForNoSessions() {
        let sut = WorkoutHistorySummary(sessions: [])

        XCTAssertEqual(sut.timesDone, 0)
        XCTAssertNil(sut.lastDone)
        XCTAssertNil(sut.averageDurationSeconds)
        XCTAssertNil(sut.averageRPE)
    }

    func test_init_deliversTimesDoneAndTheLatestSession() {
        let sut = WorkoutHistorySummary(sessions: [
            .fixture(startedAt: day(1)),
            .fixture(startedAt: day(9), endedAt: day(9).addingTimeInterval(3_600)),
            .fixture(startedAt: day(4))
        ])

        XCTAssertEqual(sut.timesDone, 3)
        XCTAssertEqual(sut.lastDone, day(9).addingTimeInterval(3_600))
    }

    // A session with no RPE has nothing to say about how hard it was. Counting it as 0 would read
    // (8 + 6 + 0) / 3 = 4.7, an easy workout that was never easy.
    func test_init_averagesRPEOverOnlyTheSessionsThatHaveOne() {
        let sut = WorkoutHistorySummary(sessions: [.fixture(rpe: 8), .fixture(rpe: 6), .fixture(rpe: nil)])

        XCTAssertEqual(sut.averageRPE ?? 0, 7, accuracy: 0.0001)
    }

    func test_init_averagesDurationOverOnlyTheSessionsThatHaveOne() {
        let sut = WorkoutHistorySummary(sessions: [
            .fixture(durationSeconds: 2_400),
            .fixture(durationSeconds: 3_000),
            .fixture()
        ])

        XCTAssertEqual(sut.averageDurationSeconds, 2_700)
    }

    // Older sessions may carry an end time but no stored duration. They still took a known time.
    func test_init_fallsBackToStartAndEndWhenNoDurationIsStored() {
        let start = day(2)
        let sut = WorkoutHistorySummary(sessions: [.fixture(startedAt: start, endedAt: start.addingTimeInterval(1_800))])

        XCTAssertEqual(sut.averageDurationSeconds, 1_800)
    }

    // A clock change mid-session can leave the end before the start. That is no duration, not a
    // negative one dragging the average down.
    func test_init_ignoresADurationThatRunsBackwards() {
        let start = day(2)
        let sut = WorkoutHistorySummary(sessions: [
            .fixture(startedAt: start, endedAt: start.addingTimeInterval(-60)),
            .fixture(durationSeconds: 3_000)
        ])

        XCTAssertEqual(sut.averageDurationSeconds, 3_000)
    }

    // A retracted session is not work done; counting it would claim a workout the user removed.
    func test_init_leavesOutDeletedSessions() {
        let sut = WorkoutHistorySummary(sessions: [
            .fixture(rpe: 9, deletedAt: day(3)),
            .fixture(rpe: 5)
        ])

        XCTAssertEqual(sut.timesDone, 1)
        XCTAssertEqual(sut.averageRPE ?? 0, 5, accuracy: 0.0001)
    }

    // MARK: - Helpers

    private func day(_ offset: Int) -> Date {
        Date(timeIntervalSince1970: 1_800_000_000).addingTimeInterval(Double(offset) * 86_400)
    }
}
