//
//  MyDayDueWorkoutsTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import XCTest
@testable import MyDayKit

final class MyDayDueWorkoutsTests: XCTestCase {

    // MARK: - Due

    func test_dueWorkouts_deliversAPlannedEntryForAWorkoutDueThatDay() {
        let sut = makeDay().dueWorkouts(schedules: [schedule()], templates: [.fixture()], calendar: london)

        XCTAssertEqual(sut.map(\.template.title), ["Morning routine"])
        XCTAssertEqual(sut.first?.status, .planned)
        XCTAssertEqual(sut.first?.scheduleId, "schedule")
        XCTAssertEqual(sut.first?.assignedDate, tuesday)
    }

    func test_dueWorkouts_deliversNothingOnADayItDoesNotFallOn() {
        let sut = makeDay().dueWorkouts(
            schedules: [schedule(recurrence: .weekly(weekdays: [.wednesday], start: .fixture("2026-11-09")))],
            templates: [.fixture()],
            calendar: london
        )

        XCTAssertEqual(sut, [])
    }

    // The day is the user's own. 00:30 on Tuesday in Tokyo is still Monday in UTC, so judged in UTC
    // the card would be missing from Tuesday morning.
    func test_dueWorkouts_judgesTheDayInTheCalendarGiven() {
        var tokyo = Calendar(identifier: .gregorian)
        tokyo.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        let earlyTuesday = tokyo.date(from: DateComponents(year: 2026, month: 11, day: 10, hour: 0, minute: 30))!

        let sut = makeDay(date: earlyTuesday).dueWorkouts(schedules: [schedule()], templates: [.fixture()], calendar: tokyo)

        XCTAssertEqual(sut.count, 1)
    }

    // The card keeps its identity across renders, and once saved. A fresh id each time would rebuild
    // the card, and two devices acting on it would write two entries.
    func test_dueWorkouts_deliversTheSameIdEveryTime() {
        let first = makeDay().dueWorkouts(schedules: [schedule()], templates: [.fixture()], calendar: london)
        let second = makeDay().dueWorkouts(schedules: [schedule()], templates: [.fixture()], calendar: london)

        XCTAssertEqual(first.map(\.id), ["schedule-2026-11-10"])
        XCTAssertEqual(first.map(\.id), second.map(\.id))
    }

    // MARK: - Hidden

    func test_dueWorkouts_leavesOutAScheduleAlreadyOnTheDay() {
        let saved = DailyWorkoutEntry(template: .fixture(id: "renamed"), assignedDate: tuesday, scheduleId: "schedule")

        let sut = makeDay(workouts: [saved]).dueWorkouts(schedules: [schedule()], templates: [.fixture()], calendar: london)

        XCTAssertEqual(sut, [])
    }

    // Two identical cards would leave the user guessing which to open.
    func test_dueWorkouts_leavesOutAWorkoutAddedByHand() {
        let added = DailyWorkoutEntry(template: .fixture(), assignedDate: tuesday)

        let sut = makeDay(workouts: [added]).dueWorkouts(schedules: [schedule()], templates: [.fixture()], calendar: london)

        XCTAssertEqual(sut, [])
    }

    func test_dueWorkouts_leavesOutAScheduleSkippedToday() {
        let day = makeDay().skippingSchedule("schedule")

        let sut = day.dueWorkouts(schedules: [schedule()], templates: [.fixture()], calendar: london)

        XCTAssertEqual(sut, [])
    }

    func test_dueWorkouts_leavesOutAStoppedSchedule() {
        let stopped = schedule(stoppedAt: tuesday)

        let sut = makeDay().dueWorkouts(schedules: [stopped], templates: [.fixture()], calendar: london)

        XCTAssertEqual(sut, [])
    }

    func test_dueWorkouts_leavesOutAWorkoutThatCannotBeFound() {
        let sut = makeDay().dueWorkouts(schedules: [schedule()], templates: [], calendar: london)

        XCTAssertEqual(sut, [])
    }

    func test_dueWorkouts_leavesOutSports() {
        let sport = Schedule(
            id: "sport",
            item: .sport(sport: .basketball, duration: 5_400),
            recurrence: .once(day: .fixture("2026-11-10")),
            createdAt: tuesday,
            updatedAt: tuesday
        )

        let sut = makeDay().dueWorkouts(schedules: [sport], templates: [.fixture()], calendar: london)

        XCTAssertEqual(sut, [])
    }

    // MARK: - Adding

    func test_addingScheduledWorkout_addsTheEntry() {
        let entry = DailyWorkoutEntry(id: "entry", template: .fixture(), assignedDate: tuesday, scheduleId: "schedule")

        let sut = makeDay().addingScheduledWorkout(entry)

        XCTAssertEqual(sut.workouts.map(\.id), ["entry"])
        XCTAssertEqual(sut.workouts.first?.scheduleId, "schedule")
    }

    // A second tap arrives with the planned copy. Replacing would wipe a session already in progress.
    func test_addingScheduledWorkout_leavesAnEntryAlreadyThereUntouched() {
        let started = DailyWorkoutEntry(id: "entry", template: .fixture(), assignedDate: tuesday, status: .inProgress, scheduleId: "schedule")
        let planned = DailyWorkoutEntry(id: "entry", template: .fixture(), assignedDate: tuesday, scheduleId: "schedule")

        let sut = makeDay(workouts: [started]).addingScheduledWorkout(planned)

        XCTAssertEqual(sut.workouts.map(\.status), [.inProgress])
    }

    // MARK: - Skipping

    func test_skippingSchedule_recordsEachScheduleOnce() {
        let sut = makeDay().skippingSchedule("a").skippingSchedule("a").skippingSchedule("b")

        XCTAssertEqual(sut.skippedSchedules, ["a", "b"])
    }

    // MARK: - Codable

    // Every day file and document written so far has none of these keys. A non-optional field would
    // fail to decode all of them, which is what once emptied the workout library.
    func test_decode_readsADayAndEntryWrittenBeforeSchedulesExisted() throws {
        let day = try JSONDecoder().decode(MyDayFullDayModel.self, from: try encodedDay(withSchedules: false))

        XCTAssertNil(day.skippedSchedules)
        XCTAssertNil(day.workouts.first?.scheduleId)
        XCTAssertEqual(day.workouts.count, 1)
    }

    func test_codable_keepsScheduleIdAndSkippedSchedules() throws {
        let day = try JSONDecoder().decode(MyDayFullDayModel.self, from: try encodedDay(withSchedules: true))

        XCTAssertEqual(day.skippedSchedules, ["skipped"])
        XCTAssertEqual(day.workouts.first?.scheduleId, "schedule")
    }

    // MARK: - Helpers

    /// Tuesday 10 November 2026, midday in London.
    private let tuesday = Date(timeIntervalSince1970: 1_794_312_000)

    private var london: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/London")!
        return calendar
    }

    private func schedule(
        recurrence: ScheduleRecurrence = .weekly(weekdays: [.tuesday], start: .fixture("2026-11-09")),
        stoppedAt: Date? = nil
    ) -> Schedule {
        Schedule.fixture(recurrence: recurrence, stoppedAt: stoppedAt)
    }

    private func makeDay(date: Date? = nil, workouts: [DailyWorkoutEntry] = []) -> MyDayFullDayModel {
        MyDayFullDayModel(id: "day", date: date ?? tuesday, exercises: [], workouts: workouts)
    }

    private func encodedDay(withSchedules: Bool) throws -> Data {
        let entry = DailyWorkoutEntry(
            template: .fixture(),
            assignedDate: tuesday,
            scheduleId: withSchedules ? "schedule" : nil
        )
        var day = makeDay(workouts: [entry])
        if withSchedules {
            day = day.skippingSchedule("skipped")
        }
        return try JSONEncoder().encode(day)
    }
}
