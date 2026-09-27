//
//  TrainingLoadMetricTests.swift
//  StatsKitTests
//
//  Created by Findlay Wood on 09/08/2026.
//

import XCTest
@testable import StatsKit

final class TrainingLoadMetricTests: XCTestCase {

    func test_sessionLoad_isZeroWhenDayHasNoWorkout() {
        // An exercise logged on its own writes a DailyTotal with volume and no
        // workload. That is a day of no *session* load, not a missing day.
        let total = makeTotal(volume: 5000, workload: nil)

        XCTAssertEqual(TrainingLoadMetric.session.load(from: total), 0)
    }

    func test_sessionLoad_readsWorkload() {
        let total = makeTotal(volume: 5000, workload: 420)

        XCTAssertEqual(TrainingLoadMetric.session.load(from: total), 420)
    }

    func test_volumeLoad_readsVolumeAndIgnoresWorkload() {
        let total = makeTotal(volume: 5000, workload: 420)

        XCTAssertEqual(TrainingLoadMetric.volume.load(from: total), 5000)
    }

    func test_loadByDay_keysEachTotalByItsDayId() {
        let totals = [
            makeTotal(id: "2026-08-01", volume: 100, workload: 10),
            makeTotal(id: "2026-08-02", volume: 200, workload: 20)
        ]

        XCTAssertEqual(
            totals.loadByDay(.volume),
            ["2026-08-01": 100, "2026-08-02": 200]
        )
        XCTAssertEqual(
            totals.loadByDay(.session),
            ["2026-08-01": 10, "2026-08-02": 20]
        )
    }

    func test_loadByDay_sumsDuplicateDayIdsRatherThanTrapping() {
        // Ids are Firestore document ids and so unique today. Building the
        // series with `Dictionary(uniqueKeysWithValues:)` would crash the tab if
        // that ever stopped being true.
        let totals = [
            makeTotal(id: "2026-08-01", volume: 100, workload: 10),
            makeTotal(id: "2026-08-01", volume: 250, workload: 5)
        ]

        XCTAssertEqual(totals.loadByDay(.volume), ["2026-08-01": 350])
    }

    // MARK: - Helpers

    private func makeTotal(
        id: String = "2026-08-01",
        volume: Double,
        workload: Double?
    ) -> DailyTotal {
        DailyTotal(
            id: id,
            date: Date(timeIntervalSince1970: 1_760_000_000),
            userID: "any",
            totalSets: 1,
            totalReps: 1,
            totalWeight: 1,
            totalVolume: volume,
            totalTime: 0,
            exerciseSetCounts: [:],
            totalWorkload: workload
        )
    }
}
