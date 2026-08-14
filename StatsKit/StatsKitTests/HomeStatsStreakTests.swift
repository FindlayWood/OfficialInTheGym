//
//  HomeStatsStreakTests.swift
//  StatsKitTests
//
//  Created by Findlay Wood on 09/08/2026.
//

import XCTest
@testable import StatsKit

final class HomeStatsStreakTests: XCTestCase {

    func test_streak_isZeroWithNoTraining() {
        let sut = makeSUT(daysAgo: [])

        XCTAssertEqual(sut.streak, 0)
    }

    func test_streak_countsConsecutiveDaysEndingToday() {
        let sut = makeSUT(daysAgo: [0, 1, 2])

        XCTAssertEqual(sut.streak, 3)
    }

    func test_streak_survivesAnUntrainedToday() {
        // The whole point: at nine in the morning a user three days into a
        // streak has not trained today yet, and still has a streak.
        let sut = makeSUT(daysAgo: [1, 2, 3])

        XCTAssertEqual(sut.streak, 3)
    }

    func test_streak_endsWhenYesterdayIsAlsoMissed() {
        let sut = makeSUT(daysAgo: [2, 3, 4])

        XCTAssertEqual(sut.streak, 0)
    }

    func test_streak_stopsAtFirstGap() {
        let sut = makeSUT(daysAgo: [0, 1, 3, 4, 5])

        XCTAssertEqual(sut.streak, 2)
    }

    func test_streak_countsOnlyToday() {
        let sut = makeSUT(daysAgo: [0])

        XCTAssertEqual(sut.streak, 1)
    }

    // MARK: - Helpers

    /// Fixed so the suite does not depend on the day it runs on.
    private var fixedDate: Date {
        Date(timeIntervalSince1970: 1_760_000_000)
    }

    private func makeSUT(daysAgo: [Int]) -> HomeStats {
        HomeStats(totals: daysAgo.map(makeTotal(daysAgo:)), asOf: fixedDate)
    }

    private func makeTotal(daysAgo: Int) -> DailyTotal {
        let date = StatsDay.date(daysAgo: daysAgo, from: fixedDate)
        return DailyTotal(
            id: StatsDay.key(for: date),
            date: date,
            userID: "any",
            totalSets: 1,
            totalReps: 1,
            totalWeight: 1,
            totalVolume: 1,
            totalTime: 0,
            exerciseSetCounts: [:]
        )
    }
}
