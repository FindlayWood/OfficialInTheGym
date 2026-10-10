//
//  WorkloadRatioTests.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//

import XCTest
@testable import PerformanceKit

final class WorkloadRatioTests: XCTestCase {

    func test_calculate_deliversAcuteAndChronicLoad() {
        let sut = ratio([.make(total: 700, daysAgo: 0), .make(total: 700, daysAgo: 10)])

        XCTAssertEqual(sut.acuteLoad, 700, accuracy: 0.0001)
        XCTAssertEqual(sut.chronicLoad, 350, accuracy: 0.0001)
        XCTAssertEqual(sut.acwr, 2, accuracy: 0.0001)
        XCTAssertEqual(sut.freshnessIndex, -350, accuracy: 0.0001)
    }

    // The chronic load is the 28-day total over four, so steady training reads
    // 1.0. A window averaged over trained days only would read differently.
    func test_calculate_deliversRatioOfOneOnSteadyLoad() {
        let sut = ratio((0..<28).map { .make(total: 100, daysAgo: $0) })

        XCTAssertEqual(sut.acwr, 1, accuracy: 0.0001)
    }

    func test_calculate_addsEverySourceOfLoad() {
        let workload = Workload(id: "a", endTime: .fixed, rpe: 5, timeToComplete: 60, workload: 1, customAddedWorkload: 10, matchWorkload: 100, practiceWorkload: 1000)

        XCTAssertEqual(ratio([workload]).acuteLoad, 1111, accuracy: 0.0001)
    }

    func test_calculate_ignoresWorkloadsOlderThanTheChronicWindow() {
        let sut = ratio([.make(total: 700, daysAgo: 28)])

        XCTAssertEqual(sut.chronicLoad, 0, accuracy: 0.0001)
    }

    // With no chronic load the ratio is 0 / 0. Stored records hold 0, never NaN,
    // so this must not change without deciding what to do with them.
    func test_calculate_storesZeroRatherThanNaNWithNoLoad() {
        let sut = ratio([])

        XCTAssertEqual(sut.acwr, 0)
        XCTAssertEqual(sut.monotony, 0)
        XCTAssertEqual(sut.trainingStrain, 0)
    }

    // Pins the legacy standard deviation, sqrt(Σ(x − mean)² / n − 1), which is
    // wrong. Every match and practice record stores monotony this way, so a fix
    // must be a decision about those records, not a quiet change here.
    func test_calculate_keepsTheLegacyMonotony() {
        let sut = ratio([.make(total: 700, daysAgo: 0)])

        let legacyStandardDeviation = sqrt(420_000.0 / 7 - 1)
        XCTAssertEqual(sut.monotony, 100 / legacyStandardDeviation, accuracy: 0.0001)
        XCTAssertEqual(sut.trainingStrain, 700 * (100 / legacyStandardDeviation), accuracy: 0.0001)
    }

    func test_calculate_measuresFromDaysBack() {
        let sut = WorkloadRatio.calculate(from: [.make(total: 700, daysAgo: 8)], daysBack: 7) {
            WorkloadRatio.daysAgo($0, now: .fixed, calendar: .utc)
        }

        XCTAssertEqual(sut.acuteLoad, 700, accuracy: 0.0001)
    }

    func test_daysAgo_countsCalendarDaysNotHours() {
        let justBeforeMidnight = Calendar.utc.date(bySettingHour: 23, minute: 59, second: 0, of: Date.fixed.addingTimeInterval(-86_400))!
        let justAfterMidnight = Calendar.utc.date(bySettingHour: 0, minute: 1, second: 0, of: .fixed)!

        XCTAssertEqual(WorkloadRatio.daysAgo(justBeforeMidnight, now: justAfterMidnight, calendar: .utc), 1)
    }

    // MARK: - Helpers

    private func ratio(_ workloads: [Workload]) -> WorkloadRatio {
        WorkloadRatio.calculate(from: workloads) { WorkloadRatio.daysAgo($0, now: .fixed, calendar: .utc) }
    }
}
