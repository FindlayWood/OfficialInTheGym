//
//  FatigueCheckTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class FatigueCheckTests: XCTestCase {

    func test_status_deliversNoneWithoutACMJ() {
        let sut = FatigueCheck(sessions: [], calendar: .utc)

        XCTAssertEqual(sut.status, .none)
        XCTAssertNil(sut.nextDue)
        XCTAssertTrue(sut.isDue(now: .fixed))
    }

    // One earlier session is too thin a max to judge against. Without the
    // calibration a second ever check would read as a confident result.
    func test_status_deliversCalibratingUntilTwoEarlierSessions() {
        let sut = FatigueCheck(sessions: [cmj("a", daysAgo: 7, 40), cmj("b", daysAgo: 0, 38)], calendar: .utc)

        XCTAssertEqual(sut.status, .calibrating(sessions: 2, needed: 3))
    }

    func test_status_deliversTheLatestBestAsAFractionOfTheRecentMax() {
        let sut = FatigueCheck(sessions: [cmj("a", daysAgo: 14, 40), cmj("b", daysAgo: 7, 42), cmj("c", daysAgo: 0, 39.9)], calendar: .utc)

        guard case .result(let fraction, let zone, let reference) = sut.status else { return XCTFail("Expected a result, got \(sut.status)") }
        XCTAssertEqual(fraction, 39.9 / 42, accuracy: 0.0001)
        XCTAssertEqual(zone, .fresh)
        XCTAssertEqual(reference.id, "b")
    }

    // The max is the best of the eight weeks before the latest session, not of
    // all time. An old peak would make every later check read as fatigued.
    func test_status_ignoresSessionsOlderThanTheWindow() {
        let sut = FatigueCheck(sessions: [
            cmj("oldPeak", daysAgo: 90, 50),
            cmj("a", daysAgo: 21, 40),
            cmj("b", daysAgo: 14, 40),
            cmj("latest", daysAgo: 0, 39)
        ], calendar: .utc)

        guard case .result(let fraction, let zone, let reference) = sut.status else { return XCTFail("Expected a result") }
        XCTAssertNotEqual(reference.id, "oldPeak")
        XCTAssertEqual(fraction, 39.0 / 40, accuracy: 0.0001)
        XCTAssertEqual(zone, .fresh)
    }

    func test_status_deliversFatiguedForABigDrop() {
        let sut = FatigueCheck(sessions: [cmj("a", daysAgo: 14, 40), cmj("b", daysAgo: 7, 40), cmj("c", daysAgo: 0, 35)], calendar: .utc)

        guard case .result(_, let zone, _) = sut.status else { return XCTFail("Expected a result") }
        XCTAssertEqual(zone, .fatigued)
    }

    // The window hangs off the latest session, so a result does not change as
    // the days pass without a new test.
    func test_status_isTheSameWhateverTheDayItIsRead() {
        let sessions = [cmj("a", daysAgo: 30, 40), cmj("b", daysAgo: 20, 41), cmj("c", daysAgo: 10, 39)]

        let sut = FatigueCheck(sessions: sessions, calendar: .utc)

        guard case .result(let fraction, _, _) = sut.status else { return XCTFail("Expected a result") }
        XCTAssertEqual(fraction, 39.0 / 41, accuracy: 0.0001)
    }

    func test_isNewBest_deliversTrueAboveTheRecentMax() {
        let sut = FatigueCheck(sessions: [cmj("a", daysAgo: 14, 40), cmj("b", daysAgo: 7, 40), cmj("c", daysAgo: 0, 42)], calendar: .utc)

        XCTAssertTrue(sut.isNewBest)
    }

    func test_status_ignoresOtherJumpTests() {
        let vertical = JumpTestSession(id: "v", kind: .verticalJump, date: .fixed, attempts: [JumpAttempt(height: 60, flightTime: nil, contactTime: nil)])

        let sut = FatigueCheck(sessions: [vertical], calendar: .utc)

        XCTAssertEqual(sut.status, .none)
    }

    func test_isDue_deliversTrueAWeekAfterTheLatest() {
        let sut = FatigueCheck(sessions: [cmj("a", daysAgo: 7, 40)], calendar: .utc)

        XCTAssertTrue(sut.isDue(now: .fixed))
        XCTAssertFalse(sut.isDue(now: Date.fixed.addingTimeInterval(-86_400)))
    }

    // MARK: - Helpers

    private func cmj(_ id: String, daysAgo: Double, _ height: Double) -> JumpTestSession {
        JumpTestSession(id: id, kind: .cmj, date: Date.fixed.addingTimeInterval(-daysAgo * 86_400), attempts: [JumpAttempt(height: height, flightTime: nil, contactTime: nil)])
    }
}
