//
//  TrackedSessionKindTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class TrackedSessionKindTests: XCTestCase {

    // A match logs the legacy flat 1000 whatever is entered, RPE 10 over two
    // hours, with the custom field written as 0.
    func test_workload_deliversTheFlatMatchLoad() {
        let sut = TrackedSessionKind.match.workload(sessionId: "s", endTime: .fixed, rpe: 3, durationMinutes: 30)

        XCTAssertEqual(sut, Workload(id: "", endTime: .fixed, rpe: 10, timeToComplete: 7200, workload: 0, customAddedWorkload: 0, matchWorkload: 1000, workoutID: "s"))
    }

    // duration × RPE × 1.5, truncated: 61 min at RPE 7 is 640.5, logged as 640.
    func test_workload_deliversPracticeLoadFromDurationAndRPE() {
        let sut = TrackedSessionKind.practice.workload(sessionId: "s", endTime: .fixed, rpe: 7, durationMinutes: 61)

        XCTAssertEqual(sut, Workload(id: "", endTime: .fixed, rpe: 7, timeToComplete: 3660, workload: 0, practiceWorkload: 640, workoutID: "s"))
    }

    func test_asksForRPEAndDuration_onlyForPractice() {
        XCTAssertFalse(TrackedSessionKind.match.asksForRPEAndDuration)
        XCTAssertTrue(TrackedSessionKind.practice.asksForRPEAndDuration)
    }
}
