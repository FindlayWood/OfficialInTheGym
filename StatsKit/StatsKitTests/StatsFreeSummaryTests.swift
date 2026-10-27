//
//  StatsFreeSummaryTests.swift
//  StatsKitTests
//
//  Created by Findlay Wood on 27/10/2026.
//

import XCTest
@testable import StatsKit

final class StatsFreeSummaryTests: XCTestCase {

    // Every test below leans on the fixed date being a Thursday: Monday is three
    // days back and Sunday three days ahead. If this fails, the rest are
    // asserting against the wrong week.
    func test_todayColumn_deliversThreeOnTheFixedThursday() {
        let sut = makeSUT(daysAgo: [])

        XCTAssertEqual(sut.todayColumn, 3)
    }

    func test_weekdayColumn_deliversZeroForMonday() {
        let monday = StatsDay.date(daysAgo: 3, from: fixedDate)

        XCTAssertEqual(StatsDay.weekdayColumn(for: monday), 0)
    }

    func test_thisWeek_deliversSevenDaysMondayFirst() {
        let sut = makeSUT(daysAgo: [])

        XCTAssertEqual(sut.thisWeek.map(\.id), Array(0..<7))
    }

    // A day that has not happened has not had the chance to be trained or not.
    // Drawing it as zero sets would shade Friday to Sunday as missed days on a
    // Thursday.
    func test_thisWeek_leavesDaysStillToComeWithoutSets() {
        let sut = makeSUT(daysAgo: [])

        XCTAssertEqual(sut.thisWeek.map(\.sets), [0, 0, 0, 0, nil, nil, nil])
    }

    func test_thisWeek_deliversSetsOnTheDaysTrained() {
        let sut = makeSUT(daysAgo: [0, 3], sets: 4)

        XCTAssertEqual(sut.thisWeek.map(\.sets), [4, 0, 0, 4, nil, nil, nil])
    }

    // Last Sunday is four days before a Thursday. A rolling seven days would
    // fold it into "this week"; the card names Monday to Sunday, so it must not.
    func test_thisWeekTotals_ignoresLastSunday() {
        let sut = makeSUT(daysAgo: [0, 3, 4])

        XCTAssertEqual(sut.thisWeekTotals.activeDays, 2)
    }

    func test_thisWeekTotals_sumsSetsAndTimeAcrossTheWeek() {
        let sut = makeSUT(daysAgo: [0, 1, 3], sets: 5)

        XCTAssertEqual(sut.thisWeekTotals.totalSets, 15)
        XCTAssertEqual(sut.thisWeekTotals.totalTime, 180)
    }

    // On a Sunday the whole week has happened: Monday is six days back and the
    // Sunday before it belongs to last week.
    func test_thisWeekTotals_includesMondayWhenTodayIsSunday() {
        let sunday = StatsDay.date(daysAgo: -3, from: fixedDate)
        let sut = makeSUT(daysAgo: [0, 6, 7], asOf: sunday)

        XCTAssertEqual(sut.todayColumn, 6)
        XCTAssertEqual(sut.thisWeekTotals.activeDays, 2)
        XCTAssertEqual(sut.daysTrainedLastWeek, 1)
    }

    func test_daysTrainedLastWeek_countsTheMondayToSundayBeforeThisWeek() {
        // 3 = this Monday, 4 = last Sunday, 10 = last Monday, 11 = the Sunday before.
        let sut = makeSUT(daysAgo: [3, 4, 10, 11])

        XCTAssertEqual(sut.daysTrainedLastWeek, 2)
    }

    func test_streak_deliversTheHomeStreak() {
        let sut = makeSUT(daysAgo: [1, 2, 3, 5])

        XCTAssertEqual(sut.streak, HomeStats(totals: sut.totals, asOf: fixedDate).streak)
        XCTAssertEqual(sut.streak, 3)
    }

    func test_topLiftCandidates_deliversExercisesByMostSetsInTheLastFourWeeks() {
        let sut = StatsFreeSummary(
            totals: [
                makeTotal(daysAgo: 0, exerciseSetCounts: ["squat": 3, "plank": 2]),
                makeTotal(daysAgo: 20, exerciseSetCounts: ["plank": 5, "bench": 1]),
            ],
            asOf: fixedDate
        )

        XCTAssertEqual(sut.topLiftCandidates, ["plank", "squat", "bench"])
    }

    // Day 28 is the first day of the *previous* window. Counting it here would
    // let a lift dropped a month ago keep the card.
    func test_topLiftCandidates_ignoresDaysOlderThanTheWindow() {
        let sut = StatsFreeSummary(
            totals: [
                makeTotal(daysAgo: 27, exerciseSetCounts: ["squat": 1]),
                makeTotal(daysAgo: 28, exerciseSetCounts: ["deadlift": 9]),
            ],
            asOf: fixedDate
        )

        XCTAssertEqual(sut.topLiftCandidates, ["squat"])
    }

    func test_topLiftCandidates_breaksTiesByIdSoTheOrderIsStable() {
        let sut = StatsFreeSummary(
            totals: [makeTotal(daysAgo: 0, exerciseSetCounts: ["row": 2, "curl": 2, "press": 2])],
            asOf: fixedDate
        )

        XCTAssertEqual(sut.topLiftCandidates, ["curl", "press", "row"])
    }

    // MARK: - Helpers

    /// Fixed so the suite does not depend on the day it runs on. A Thursday, in UTC.
    private var fixedDate: Date {
        Date(timeIntervalSince1970: 1_760_000_000)
    }

    private func makeSUT(daysAgo: [Int], sets: Int = 1, asOf: Date? = nil) -> StatsFreeSummary {
        let asOf = asOf ?? fixedDate
        return StatsFreeSummary(
            totals: daysAgo.map { makeTotal(daysAgo: $0, sets: sets, from: asOf) },
            asOf: asOf
        )
    }

    private func makeTotal(
        daysAgo: Int,
        sets: Int = 1,
        exerciseSetCounts: [String: Int] = [:],
        from asOf: Date? = nil
    ) -> DailyTotal {
        let date = StatsDay.date(daysAgo: daysAgo, from: asOf ?? fixedDate)
        return DailyTotal(
            id: StatsDay.key(for: date),
            date: date,
            userID: "any",
            totalSets: sets,
            totalReps: 10,
            totalWeight: 50,
            totalVolume: 100,
            totalTime: 60,
            exerciseSetCounts: exerciseSetCounts
        )
    }
}
