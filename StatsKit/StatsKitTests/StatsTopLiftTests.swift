//
//  StatsTopLiftTests.swift
//  StatsKitTests
//
//  Created by Findlay Wood on 27/10/2026.
//

import XCTest
@testable import StatsKit

final class StatsTopLiftTests: XCTestCase {

    func test_init_deliversNilWithNoStats() {
        let sut = makeSUT([])

        XCTAssertNil(sut)
    }

    // Bodyweight, timed and % of 1RM work all store a maxWeight of 0. A card
    // reading "Plank 0 kg" would be a reading of nothing.
    func test_init_deliversNilWithNoWeightedSetInTheLastFourWeeks() {
        let sut = makeSUT([day(0, maxWeight: 0), day(5, maxWeight: 0)])

        XCTAssertNil(sut)
    }

    // A lift last lifted five weeks ago is not this month's top lift, however
    // heavy it was.
    func test_init_deliversNilWhenTheOnlyWeightedSetIsInThePreviousWindow() {
        let sut = makeSUT([day(30, maxWeight: 100)])

        XCTAssertNil(sut)
    }

    func test_init_deliversTheHeaviestSetInTheLastFourWeeks() {
        let sut = makeSUT([day(0, maxWeight: 95), day(10, maxWeight: 100), day(27, maxWeight: 90)])

        XCTAssertEqual(sut?.recentBest ?? 0, 100, accuracy: 0.001)
    }

    func test_change_deliversTheDifferenceFromTheFourWeeksBefore() {
        let sut = makeSUT([day(2, maxWeight: 102.5), day(35, maxWeight: 97.5), day(50, maxWeight: 95)])

        XCTAssertEqual(sut?.previousBest ?? 0, 97.5, accuracy: 0.001)
        XCTAssertEqual(sut?.change ?? 0, 5, accuracy: 0.001)
    }

    func test_change_deliversANegativeChangeForALighterMonth() {
        let sut = makeSUT([day(2, maxWeight: 90), day(40, maxWeight: 100)])

        XCTAssertEqual(sut?.change ?? 0, -10, accuracy: 0.001)
    }

    // A first appearance is not a gain from zero — with nothing before it there
    // is no change to report, not "+100 kg".
    func test_change_deliversNilWithNothingInThePreviousWindow() {
        let sut = makeSUT([day(2, maxWeight: 100)])

        XCTAssertNotNil(sut)
        XCTAssertNil(sut?.change)
    }

    // Day 56 is outside both windows. Folding it into the previous one would
    // compare against however much history happened to be fetched.
    func test_previousBest_ignoresDaysOlderThanEightWeeks() {
        let sut = makeSUT([day(0, maxWeight: 80), day(56, maxWeight: 120)])

        XCTAssertNil(sut?.previousBest)
    }

    func test_previousBest_ignoresUnweightedDays() {
        let sut = makeSUT([day(0, maxWeight: 80), day(30, maxWeight: 0)])

        XCTAssertNil(sut?.previousBest)
    }

    func test_init_takesTheNameFromTheNewestDay() {
        let sut = makeSUT([day(9, maxWeight: 80, name: "Squat"), day(1, maxWeight: 80, name: "Back Squat")])

        XCTAssertEqual(sut?.name, "Back Squat")
    }

    func test_init_skipsAMissingNameForAnOlderOne() {
        let sut = makeSUT([day(9, maxWeight: 80, name: "Squat"), day(1, maxWeight: 80, name: nil)])

        XCTAssertEqual(sut?.name, "Squat")
    }

    func test_fetchStart_coversBothWindows() {
        XCTAssertEqual(StatsTopLift.fetchStart(asOf: fixedDate), StatsDay.startOfDay(daysAgo: 55, from: fixedDate))
    }

    // MARK: - Helpers

    /// Fixed so the suite does not depend on the day it runs on.
    private var fixedDate: Date {
        Date(timeIntervalSince1970: 1_760_000_000)
    }

    private func makeSUT(_ stats: [ExerciseDailyStats]) -> StatsTopLift? {
        StatsTopLift(exerciseID: "squat", stats: stats, asOf: fixedDate)
    }

    private func day(_ daysAgo: Int, maxWeight: Double, name: String? = "Back Squat") -> ExerciseDailyStats {
        let date = StatsDay.date(daysAgo: daysAgo, from: fixedDate)
        return ExerciseDailyStats(
            id: StatsDay.key(for: date),
            date: date,
            exerciseID: "squat",
            exerciseName: name,
            userID: "any",
            totalSets: 3,
            totalReps: 15,
            totalWeight: maxWeight * 3,
            totalVolume: maxWeight * 15,
            totalTime: 0,
            maxWeight: maxWeight,
            maxTime: 0
        )
    }
}
