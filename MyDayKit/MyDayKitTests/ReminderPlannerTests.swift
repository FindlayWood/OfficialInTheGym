//
//  ReminderPlannerTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import XCTest
@testable import MyDayKit

final class ReminderPlannerTests: XCTestCase {

    // MARK: - Nothing on

    func test_plan_deliversNothingWhenEveryReminderIsOff() {
        let sut = ReminderPlanner.plan(preferences: .default, today: .none, now: tuesdayAt(7), calendar: london)

        XCTAssertTrue(sut.isEmpty)
    }

    // MARK: - Check-in

    func test_plan_deliversOneCheckInPerDayAcrossTheHorizon() {
        let sut = ReminderPlanner.plan(preferences: checkInOn(), today: .none, now: tuesdayAt(7), calendar: london)

        XCTAssertEqual(sut.count, ReminderPlanner.horizonDays)
        XCTAssertEqual(sut.first?.identifier, "reminder.checkIn.2026-11-10")
        XCTAssertEqual(sut.last?.identifier, "reminder.checkIn.2026-11-23")
    }

    func test_plan_deliversCheckInAtTheChosenTime() {
        let sut = ReminderPlanner.plan(preferences: checkInOn(time: ReminderTime(hour: 7, minute: 45)), today: .none, now: tuesdayAt(7), calendar: london)

        XCTAssertEqual(sut.first?.fireDate, london.date(from: DateComponents(year: 2026, month: 11, day: 10, hour: 7, minute: 45)))
    }

    // The whole point: a check-in made before the reminder fires must remove it, or the nudge
    // arrives after the thing it asks for is done.
    func test_plan_skipsTodaysCheckInOnceCheckedIn() {
        let sut = ReminderPlanner.plan(preferences: checkInOn(), today: markers(checkIn: true), now: tuesdayAt(7), calendar: london)

        XCTAssertEqual(sut.first?.identifier, "reminder.checkIn.2026-11-11")
    }

    // A request for a moment already gone would fire at once on scheduling — opening the app at
    // nine would be greeted with the eight o'clock reminder.
    func test_plan_skipsTodaysCheckInOnceItsTimeHasPassed() {
        let sut = ReminderPlanner.plan(preferences: checkInOn(), today: .none, now: tuesdayAt(9), calendar: london)

        XCTAssertEqual(sut.first?.identifier, "reminder.checkIn.2026-11-11")
    }

    func test_plan_deliversCheckInsOnlyOnChosenWeekdays() {
        let sut = ReminderPlanner.plan(preferences: checkInOn(weekdays: [.monday]), today: .none, now: tuesdayAt(7), calendar: london)

        XCTAssertEqual(sut.map(\.identifier), ["reminder.checkIn.2026-11-16", "reminder.checkIn.2026-11-23"])
    }

    func test_plan_deliversNoCheckInsWithNoWeekdaysChosen() {
        let sut = ReminderPlanner.plan(preferences: checkInOn(weekdays: []), today: .none, now: tuesdayAt(7), calendar: london)

        XCTAssertTrue(sut.isEmpty)
    }

    // The clocks go forward on 28 March 2027. A reminder kept as a stored instant would fire at
    // 09:00 from then on; an hour and a minute applied to each day stay at 08:00.
    func test_plan_keepsTheTimeOfDayAcrossAClockChange() {
        let saturday = london.date(from: DateComponents(year: 2027, month: 3, day: 27, hour: 7))!

        let sut = ReminderPlanner.plan(preferences: checkInOn(), today: .none, now: saturday, calendar: london)

        XCTAssertEqual(Set(sut.map { london.component(.hour, from: $0.fireDate) }), [8])
        XCTAssertTrue(sut.contains { $0.identifier == "reminder.checkIn.2027-03-28" })
    }

    // MARK: - Day rating

    // Rating does not open on MyDay until something is recorded, so a reminder before then
    // would send the user to a step they cannot use.
    func test_plan_deliversNoRatingOnADayWithNothingRecorded() {
        let sut = ReminderPlanner.plan(preferences: ratingOn(), today: .none, now: tuesdayAt(7), calendar: london)

        XCTAssertTrue(sut.isEmpty)
    }

    func test_plan_deliversTodaysRatingOnlyOnceTrainingIsRecorded() {
        let sut = ReminderPlanner.plan(preferences: ratingOn(), today: markers(exercise: true), now: tuesdayAt(7), calendar: london)

        XCTAssertEqual(sut.map(\.identifier), ["reminder.dayRating.2026-11-10"])
    }

    func test_plan_deliversNoRatingOnceRated() {
        let sut = ReminderPlanner.plan(preferences: ratingOn(), today: markers(exercise: true, rpe: true), now: tuesdayAt(7), calendar: london)

        XCTAssertTrue(sut.isEmpty)
    }

    func test_plan_deliversNoRatingOnceItsTimeHasPassed() {
        let sut = ReminderPlanner.plan(preferences: ratingOn(), today: markers(exercise: true), now: tuesdayAt(21), calendar: london)

        XCTAssertTrue(sut.isEmpty)
    }

    func test_plan_deliversRemindersInFiringOrder() {
        var preferences = checkInOn()
        preferences.dayRating = ReminderPreference(isOn: true, time: .evening)

        let sut = ReminderPlanner.plan(preferences: preferences, today: markers(exercise: true), now: tuesdayAt(7), calendar: london)

        XCTAssertEqual(sut.prefix(3).map(\.identifier), [
            "reminder.checkIn.2026-11-10",
            "reminder.dayRating.2026-11-10",
            "reminder.checkIn.2026-11-11"
        ])
    }

    // MARK: - Helpers

    private let london: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/London")!
        return calendar
    }()

    /// Tuesday 10 November 2026, at `hour` in London.
    private func tuesdayAt(_ hour: Int) -> Date {
        london.date(from: DateComponents(year: 2026, month: 11, day: 10, hour: hour))!
    }

    private func checkInOn(time: ReminderTime = .morning, weekdays: Set<ScheduleWeekday> = Set(ScheduleWeekday.allCases)) -> ReminderPreferences {
        var preferences = ReminderPreferences.default
        preferences.checkIn = ReminderPreference(isOn: true, time: time, weekdays: weekdays)
        return preferences
    }

    private func ratingOn() -> ReminderPreferences {
        var preferences = ReminderPreferences.default
        preferences.dayRating = ReminderPreference(isOn: true, time: .evening)
        return preferences
    }

    private func markers(checkIn: Bool = false, exercise: Bool = false, rpe: Bool = false) -> MyDayDayMarkers {
        MyDayDayMarkers(hasCheckIn: checkIn, hasExercise: exercise, hasRPE: rpe)
    }
}
