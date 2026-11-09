//
//  ScheduledListRowTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import XCTest
@testable import MyDayKit

final class ScheduledListRowTests: XCTestCase {

    func test_rows_namesAWorkoutFromTheLibrary() {
        let sut = ScheduledListRow.rows(schedules: [.fixture()], templates: [.fixture()], today: today)

        XCTAssertEqual(sut.map(\.title), ["Morning routine"])
        XCTAssertEqual(sut.map(\.icon), ["dumbbell.fill"])
    }

    // It may only mean the library has not loaded, and this is the one place the user could stop it.
    func test_rows_keepsAWorkoutNotFoundInTheLibrary() {
        let sut = ScheduledListRow.rows(schedules: [.fixture()], templates: [], today: today)

        XCTAssertEqual(sut.map(\.title), ["Workout"])
    }

    func test_rows_namesASportFromItsType() {
        let sut = ScheduledListRow.rows(schedules: [sport(.basketball)], templates: [], today: today)

        XCTAssertEqual(sut.map(\.title), ["Basketball"])
        XCTAssertEqual(sut.map(\.icon), [SportType.basketball.icon])
    }

    func test_rows_ordersSoonestFirst() {
        let later = Schedule.fixture(id: "later", recurrence: .once(day: .fixture("2026-12-01")))
        let sooner = Schedule.fixture(id: "sooner", recurrence: .once(day: .fixture("2026-11-12")))

        let sut = ScheduledListRow.rows(schedules: [later, sooner], templates: [], today: today)

        XCTAssertEqual(sut.map(\.id), ["sooner", "later"])
        XCTAssertEqual(sut.map(\.nextDay), [.fixture("2026-11-12"), .fixture("2026-12-01")])
    }

    // `sorted` is not stable across launches of a merged list, so without this two schedules on one
    // day could swap places between visits.
    func test_rows_ordersTheSameDayByName() {
        let golf = sport(.golf, id: "golf")
        let basketball = sport(.basketball, id: "basketball")

        let sut = ScheduledListRow.rows(schedules: [golf, basketball], templates: [], today: today)

        XCTAssertEqual(sut.map(\.title), ["Basketball", "Golf"])
    }

    func test_rows_leavesOutStoppedSchedulesAndFinishedOneOffs() {
        let stopped = Schedule.fixture(id: "stopped", stoppedAt: fixedDate)
        let finished = Schedule.fixture(id: "finished", recurrence: .once(day: .fixture("2026-11-01")))

        let sut = ScheduledListRow.rows(schedules: [stopped, finished], templates: [], today: today)

        XCTAssertEqual(sut, [])
    }

    // MARK: - Summary

    func test_summary_deliversTheRecurrenceAloneForAWorkout() {
        XCTAssertEqual(Schedule.fixture().summary, "Every Tue")
    }

    func test_summary_addsTheUsualTimeForASport() {
        XCTAssertEqual(sport(.basketball).summary, "Tue 10 Nov · 1h 30m")
    }

    // MARK: - Helpers

    private let today = ScheduleDay.fixture("2026-11-09")
    private let fixedDate = Date(timeIntervalSince1970: 1_800_000_000)

    private func sport(_ sport: SportType, id: String = "sport") -> Schedule {
        Schedule(
            id: id,
            item: .sport(sport: sport, duration: 5_400),
            recurrence: .once(day: .fixture("2026-11-10")),
            createdAt: fixedDate,
            updatedAt: fixedDate
        )
    }
}
