//
//  InjuryLoadReportTests.swift
//  StatsKitTests
//
//  Created by Findlay Wood on 10/11/2026.
//

import XCTest
@testable import StatsKit

final class InjuryLoadReportTests: XCTestCase {

    // MARK: - Before

    // The peak's oldest point needs 28 days of chronic history behind it. Computed over days
    // that were never fetched, chronic reads too low and the page would show a spike that
    // never happened.
    func test_init_deliversNoBeforeWhenItsWindowWasNotFetched() {
        let sut = InjuryLoadReport(injury: .fixture(startedDaysAgo: 70, from: today), totals: steady(100, days: 119), today: today)

        XCTAssertNil(sut.before)
    }

    func test_init_deliversBothMetricsSessionFirst() {
        let sut = InjuryLoadReport(injury: .fixture(startedDaysAgo: 10, from: today), totals: steady(100, days: 119), today: today)

        XCTAssertEqual(sut.before?.map(\.metric), [.session, .volume])
    }

    func test_init_deliversARatioOfOneAtTheStartOfSteadyLoad() throws {
        let sut = InjuryLoadReport(injury: .fixture(startedDaysAgo: 10, from: today), totals: steady(100, days: 119), today: today)

        let volume = try XCTUnwrap(sut.before?.last)
        XCTAssertEqual(try XCTUnwrap(volume.atStart.ratio), 1.0, accuracy: 0.0001)
    }

    // A single heavy day a week and a half before an injury is the shape the page exists to
    // show. It must be found inside the four weeks, not averaged away.
    func test_init_deliversThePeakInTheFourWeeksBefore() throws {
        var totals = steady(100, days: 119).filter { $0.id != StatsDay.key(daysAgo: 20, from: today) }
        totals.append(.fixture(daysAgo: 20, from: today, volume: 1000, workload: 1000))
        let sut = InjuryLoadReport(injury: .fixture(startedDaysAgo: 10, from: today), totals: totals, today: today)

        let peak = try XCTUnwrap(sut.before?.last?.peak)
        let acute: Double = (6 * 100 + 1000) / 7
        let chronic: Double = (27 * 100 + 1000) / 28
        XCTAssertEqual(peak.ratio, acute / chronic, accuracy: 0.01)
        XCTAssertTrue((4...10).contains(peak.daysBefore))
    }

    func test_init_deliversWeekOnWeekChangeBeforeTheStart() throws {
        let totals = (1...7).map { DailyTotal.fixture(daysAgo: 10 + $0, from: today, volume: 200) }
            + (8...60).map { DailyTotal.fixture(daysAgo: 10 + $0, from: today, volume: 100) }
        let sut = InjuryLoadReport(injury: .fixture(startedDaysAgo: 10, from: today), totals: totals, today: today)

        XCTAssertEqual(try XCTUnwrap(sut.before?.last?.weekOnWeekChange), 1.0, accuracy: 0.0001)
    }

    // A percentage on nothing is not a number worth showing.
    func test_init_deliversNoWeekOnWeekChangeAfterAnEmptyWeek() {
        let totals = (1...7).map { DailyTotal.fixture(daysAgo: 10 + $0, from: today, volume: 200) }
        let sut = InjuryLoadReport(injury: .fixture(startedDaysAgo: 10, from: today), totals: totals, today: today)

        XCTAssertNil(sut.before?.last?.weekOnWeekChange)
    }

    // MARK: - During

    // A per-week rate from two days is a guess dressed as a number.
    func test_init_deliversNoDuringUnderAWeek() {
        let sut = InjuryLoadReport(injury: .fixture(startedDaysAgo: 3, from: today), totals: steady(100, days: 60), today: today)

        XCTAssertNil(sut.during)
    }

    // Rest days count as zero, as in the ACWR, so a fortnight with two sessions reads as one a
    // week — not as two sessions on every day trained.
    func test_init_deliversRatesPerWeekCountingRestDays() throws {
        let totals = [
            DailyTotal.fixture(daysAgo: 2, from: today, sets: 10),
            DailyTotal.fixture(daysAgo: 9, from: today, sets: 10)
        ]
        let sut = InjuryLoadReport(injury: .fixture(startedDaysAgo: 13, from: today), totals: totals, today: today)

        let during = try XCTUnwrap(sut.during)
        XCTAssertEqual(during.days, 14)
        XCTAssertEqual(during.rates.daysTrainedPerWeek, 1.0, accuracy: 0.0001)
        XCTAssertEqual(during.rates.setsPerWeek, 10.0, accuracy: 0.0001)
    }

    func test_init_comparesWithTheFourWeeksBeforeItStarted() throws {
        let before = [20, 25, 30, 35].map { DailyTotal.fixture(daysAgo: $0, from: today, sets: 5) }
        let sut = InjuryLoadReport(injury: .fixture(startedDaysAgo: 13, from: today), totals: before, today: today)

        let ratesBefore = try XCTUnwrap(sut.during?.ratesBefore)
        XCTAssertEqual(ratesBefore.daysTrainedPerWeek, 1.0, accuracy: 0.0001)
        XCTAssertEqual(ratesBefore.setsPerWeek, 5.0, accuracy: 0.0001)
    }

    // A cleared injury's last day is the day before it cleared. Counting the clear day would
    // put the first normal session inside the injury.
    func test_init_stopsCountingTheDayBeforeItCleared() throws {
        let totals = [DailyTotal.fixture(daysAgo: 5, from: today, sets: 30)]
        let sut = InjuryLoadReport(injury: .fixture(startedDaysAgo: 20, resolvedDaysAgo: 5, from: today), totals: totals, today: today)

        let during = try XCTUnwrap(sut.during)
        XCTAssertEqual(during.days, 15)
        XCTAssertEqual(during.rates.setsPerWeek, 0, accuracy: 0.0001)
    }

    func test_init_deliversTopMuscleGroupsByShareOfVolume() throws {
        let totals = [
            DailyTotal.fixture(daysAgo: 1, from: today, muscleGroupVolumes: ["chest": 300, "quads": 100]),
            DailyTotal.fixture(daysAgo: 2, from: today, muscleGroupVolumes: ["chest": 300, "back": 300])
        ]
        let sut = InjuryLoadReport(injury: .fixture(startedDaysAgo: 10, from: today), totals: totals, today: today)

        let groups = try XCTUnwrap(sut.during?.topMuscleGroups)
        XCTAssertEqual(groups.map(\.id), ["chest", "back", "quads"])
        XCTAssertEqual(groups[0].share, 0.6, accuracy: 0.0001)
    }

    // MARK: - Helpers

    /// 10 November 2026, the start of the day in UTC — the calendar the keys are read in.
    private var today: Date {
        DateFormatter.yyyyMMdd.date(from: "2026-11-10")!
    }

    /// `value` of both loads on each of the last `days` days, today included.
    private func steady(_ value: Double, days: Int) -> [DailyTotal] {
        (0..<days).map { DailyTotal.fixture(daysAgo: $0, from: today, volume: value, workload: value, sets: 1) }
    }
}
