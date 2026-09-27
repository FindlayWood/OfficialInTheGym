//
//  TrainingWeekTests.swift
//  StatsKitTests
//
//  Created by Findlay Wood on 13/08/2026.
//

import XCTest
@testable import StatsKit

final class TrainingWeekTests: XCTestCase {

    func test_buckets_deliversRequestedNumberOfWeeksOldestFirst() {
        let sut = makeSUT(daysAgo: [], weeks: 12)

        XCTAssertEqual(sut.count, 12)
        XCTAssertEqual(sut.map(\.id), Array(0..<12))
    }

    func test_buckets_deliversEmptyWeeksWithNoTotals() {
        let sut = makeSUT(daysAgo: [], weeks: 12)

        XCTAssertTrue(sut.allSatisfy(\.isEmpty))
    }

    func test_buckets_placesTodayInTheNewestWeek() {
        let sut = makeSUT(daysAgo: [0], weeks: 12)

        XCTAssertEqual(sut.last?.sets, 1)
        XCTAssertTrue(sut.dropLast().allSatisfy(\.isEmpty))
    }

    // The newest bucket is a rolling seven days — days 0 through 6 — not a
    // calendar week. Bucketing by calendar week would move day 6 into the
    // previous bar for most of any given week.
    func test_buckets_newestWeekCoversSevenDaysEndingToday() {
        let sut = makeSUT(daysAgo: [0, 1, 2, 3, 4, 5, 6], weeks: 12)

        XCTAssertEqual(sut.last?.sets, 7)
        XCTAssertTrue(sut.dropLast().allSatisfy(\.isEmpty))
    }

    func test_buckets_placesTheEighthDayAgoInThePreviousWeek() {
        let sut = makeSUT(daysAgo: [7], weeks: 12)

        XCTAssertEqual(sut.last?.sets, 0)
        XCTAssertEqual(sut[sut.count - 2].sets, 1)
    }

    func test_buckets_sumsEveryMeasureAcrossTheWeek() {
        let sut = makeSUT(daysAgo: [0, 2, 5], weeks: 12)
        let newest = sut.last

        XCTAssertEqual(newest?.sets, 3)
        XCTAssertEqual(newest?.reps, 30)
        XCTAssertEqual(newest?.volume ?? 0, 300, accuracy: 0.001)
        XCTAssertEqual(newest?.time, 180)
    }

    // A day older than the requested window must not be folded into the oldest
    // bucket — that would make the leftmost bar a dumping ground that grows with
    // however much history happens to have been fetched.
    func test_buckets_ignoresDaysOlderThanTheWindow() {
        let sut = makeSUT(daysAgo: [84], weeks: 12)

        XCTAssertTrue(sut.allSatisfy(\.isEmpty))
    }

    func test_buckets_deliversStartDateSixDaysBeforeTheBucketEnd() {
        let sut = makeSUT(daysAgo: [], weeks: 2)

        XCTAssertEqual(sut.last?.start, StatsDay.date(daysAgo: 6, from: fixedDate))
        XCTAssertEqual(sut.first?.start, StatsDay.date(daysAgo: 13, from: fixedDate))
    }

    // MARK: - Helpers

    /// Fixed so the suite does not depend on the day it runs on.
    private var fixedDate: Date {
        Date(timeIntervalSince1970: 1_760_000_000)
    }

    private func makeSUT(daysAgo: [Int], weeks: Int) -> [TrainingWeek] {
        TrainingWeek.buckets(
            from: daysAgo.map(makeTotal(daysAgo:)),
            weeks: weeks,
            endingOn: fixedDate
        )
    }

    private func makeTotal(daysAgo: Int) -> DailyTotal {
        let date = StatsDay.date(daysAgo: daysAgo, from: fixedDate)
        return DailyTotal(
            id: StatsDay.key(for: date),
            date: date,
            userID: "any",
            totalSets: 1,
            totalReps: 10,
            totalWeight: 50,
            totalVolume: 100,
            totalTime: 60,
            exerciseSetCounts: [:]
        )
    }
}
