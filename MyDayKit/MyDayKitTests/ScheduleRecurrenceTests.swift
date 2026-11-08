//
//  ScheduleRecurrenceTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 08/11/2026.
//

import XCTest
@testable import MyDayKit

final class ScheduleRecurrenceTests: XCTestCase {

    // MARK: - Once

    func test_occurs_deliversTrueOnlyOnTheOneDay() {
        let sut = ScheduleRecurrence.once(day: .fixture("2026-11-10"))

        XCTAssertTrue(sut.occurs(on: .fixture("2026-11-10")))
        XCTAssertFalse(sut.occurs(on: .fixture("2026-11-09")))
        XCTAssertFalse(sut.occurs(on: .fixture("2026-11-17")))
    }

    func test_nextOccurrence_deliversTheOneDayUntilItHasPassed() {
        let sut = ScheduleRecurrence.once(day: .fixture("2026-11-10"))

        XCTAssertEqual(sut.nextOccurrence(onOrAfter: .fixture("2026-11-08")), .fixture("2026-11-10"))
        XCTAssertEqual(sut.nextOccurrence(onOrAfter: .fixture("2026-11-10")), .fixture("2026-11-10"))
        XCTAssertNil(sut.nextOccurrence(onOrAfter: .fixture("2026-11-11")))
    }

    // MARK: - Weekly

    func test_occurs_deliversTrueOnEveryChosenWeekday() {
        let sut = ScheduleRecurrence.weekly(weekdays: [.tuesday, .thursday], start: .fixture("2026-11-09"))

        XCTAssertTrue(sut.occurs(on: .fixture("2026-11-10")))
        XCTAssertTrue(sut.occurs(on: .fixture("2026-11-12")))
        XCTAssertTrue(sut.occurs(on: .fixture("2026-11-17")))
        XCTAssertFalse(sut.occurs(on: .fixture("2026-11-11")))
    }

    // Saved on a Thursday, "every Tuesday" begins next week. Without the floor, a schedule would
    // also claim days from before it existed.
    func test_occurs_deliversFalseBeforeTheStartOnAChosenWeekday() {
        let sut = ScheduleRecurrence.weekly(weekdays: [.tuesday], start: .fixture("2026-11-12"))

        XCTAssertFalse(sut.occurs(on: .fixture("2026-11-10")))
        XCTAssertTrue(sut.occurs(on: .fixture("2026-11-17")))
    }

    // Picking today's weekday means it is due today, so the start day itself must count.
    func test_occurs_deliversTrueOnTheStartDay() {
        let sut = ScheduleRecurrence.weekly(weekdays: [.tuesday], start: .fixture("2026-11-10"))

        XCTAssertTrue(sut.occurs(on: .fixture("2026-11-10")))
    }

    // A damaged document must draw nothing, not a card on every day.
    func test_occurs_deliversFalseForRepeatWithNoWeekdays() {
        let sut = ScheduleRecurrence.weekly(weekdays: [], start: .fixture("2026-11-10"))

        XCTAssertFalse(sut.occurs(on: .fixture("2026-11-10")))
    }

    func test_nextOccurrence_deliversToday_whenDueToday() {
        let sut = ScheduleRecurrence.weekly(weekdays: [.tuesday, .thursday], start: .fixture("2026-11-09"))

        XCTAssertEqual(sut.nextOccurrence(onOrAfter: .fixture("2026-11-10")), .fixture("2026-11-10"))
    }

    func test_nextOccurrence_deliversNearestChosenWeekday() {
        let sut = ScheduleRecurrence.weekly(weekdays: [.tuesday, .thursday], start: .fixture("2026-11-09"))

        XCTAssertEqual(sut.nextOccurrence(onOrAfter: .fixture("2026-11-11")), .fixture("2026-11-12"))
        XCTAssertEqual(sut.nextOccurrence(onOrAfter: .fixture("2026-11-13")), .fixture("2026-11-17"))
    }

    func test_nextOccurrence_deliversFirstDayFromStart_whenStartIsAhead() {
        let sut = ScheduleRecurrence.weekly(weekdays: [.tuesday], start: .fixture("2026-12-01"))

        XCTAssertEqual(sut.nextOccurrence(onOrAfter: .fixture("2026-11-10")), .fixture("2026-12-01"))
    }

    func test_nextOccurrence_deliversNilForRepeatWithNoWeekdays() {
        let sut = ScheduleRecurrence.weekly(weekdays: [], start: .fixture("2026-11-10"))

        XCTAssertNil(sut.nextOccurrence(onOrAfter: .fixture("2026-11-10")))
    }

    // MARK: - Every two weeks

    func test_occurs_deliversTrueOnAlternateWeeks() {
        let sut = ScheduleRecurrence.everyTwoWeeks(weekdays: [.tuesday], start: .fixture("2026-11-10"))

        XCTAssertTrue(sut.occurs(on: .fixture("2026-11-10")))
        XCTAssertFalse(sut.occurs(on: .fixture("2026-11-17")))
        XCTAssertTrue(sut.occurs(on: .fixture("2026-11-24")))
        XCTAssertFalse(sut.occurs(on: .fixture("2026-12-01")))
    }

    // Every chosen day in an on week falls, and none in an off week. Counting fourteen days from the
    // start day rather than Monday-based weeks would split a week's Monday and Sunday into different
    // phases: the 15th and 16th below are a day apart, and only the 15th is in the on week.
    func test_occurs_keepsAllChosenWeekdaysInTheSameWeeks() {
        let sut = ScheduleRecurrence.everyTwoWeeks(weekdays: [.monday, .sunday], start: .fixture("2026-11-11"))

        XCTAssertTrue(sut.occurs(on: .fixture("2026-11-15")))
        XCTAssertFalse(sut.occurs(on: .fixture("2026-11-16")))
        XCTAssertFalse(sut.occurs(on: .fixture("2026-11-22")))
        XCTAssertTrue(sut.occurs(on: .fixture("2026-11-23")))
        XCTAssertTrue(sut.occurs(on: .fixture("2026-11-29")))
    }

    func test_occurs_keepsTheWeeksAcrossAYearEnd() {
        let sut = ScheduleRecurrence.everyTwoWeeks(weekdays: [.tuesday], start: .fixture("2026-12-22"))

        XCTAssertFalse(sut.occurs(on: .fixture("2026-12-29")))
        XCTAssertTrue(sut.occurs(on: .fixture("2027-01-05")))
        XCTAssertFalse(sut.occurs(on: .fixture("2027-01-12")))
    }

    // London's clocks went back on 25 October 2026, so that day was 25 hours. Dividing elapsed time
    // instead of counting calendar days could put the days around midnight in the wrong week.
    func test_occurs_keepsTheWeeksAcrossAClockChange() {
        let london = calendar("Europe/London")
        let sut = ScheduleRecurrence.everyTwoWeeks(weekdays: [.tuesday], start: .fixture("2026-10-13"))

        let justAfterMidnight = dateComponents(2026, 10, 27, hour: 0, minute: 5, in: london)
        let justBeforeMidnight = dateComponents(2026, 10, 27, hour: 23, minute: 55, in: london)

        XCTAssertTrue(sut.occurs(on: ScheduleDay(justAfterMidnight, calendar: london)))
        XCTAssertTrue(sut.occurs(on: ScheduleDay(justBeforeMidnight, calendar: london)))
        XCTAssertFalse(sut.occurs(on: ScheduleDay(justAfterMidnight, calendar: london).adding(days: 7)))
    }

    // Tuesday has already passed in the start week, and the next week is off, so the sheet must say
    // the Tuesday after that. Saying next Tuesday would promise a card that never appears.
    func test_nextOccurrence_skipsOffWeek_whenStartIsAfterTheWeekday() {
        let sut = ScheduleRecurrence.everyTwoWeeks(weekdays: [.tuesday], start: .fixture("2026-11-12"))

        XCTAssertEqual(sut.nextOccurrence(onOrAfter: .fixture("2026-11-12")), .fixture("2026-11-24"))
    }

    func test_nextOccurrence_deliversDayThatOccurs_fromEveryStartingPoint() {
        let sut = ScheduleRecurrence.everyTwoWeeks(weekdays: [.saturday], start: .fixture("2026-11-09"))
        let days = (0..<60).map { ScheduleDay.fixture("2026-11-09").adding(days: $0) }

        for day in days {
            let next = sut.nextOccurrence(onOrAfter: day)

            XCTAssertNotNil(next, "from \(day.key)")
            XCTAssertEqual(next.map(sut.occurs(on:)), true, "from \(day.key)")
        }
    }

    // MARK: - Codable

    func test_codable_deliversSameRecurrenceForEveryCase() throws {
        let recurrences: [ScheduleRecurrence] = [
            .once(day: .fixture("2026-11-10")),
            .weekly(weekdays: [.tuesday, .thursday], start: .fixture("2026-11-09")),
            .everyTwoWeeks(weekdays: [.saturday], start: .fixture("2026-11-09"))
        ]

        let data = try JSONEncoder().encode(recurrences)

        XCTAssertEqual(try JSONDecoder().decode([ScheduleRecurrence].self, from: data), recurrences)
    }

    // A frequency this version does not know must fail, so the store skips that one document rather
    // than reading it as something else. It is what makes adding monthly later safe.
    func test_decode_throwsOnUnknownFrequency() {
        let data = Data(#"{"monthly":{"day":31}}"#.utf8)

        XCTAssertThrowsError(try JSONDecoder().decode(ScheduleRecurrence.self, from: data))
    }

    // MARK: - Helpers

    private func calendar(_ zone: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: zone)!
        return calendar
    }

    private func dateComponents(_ year: Int, _ month: Int, _ day: Int, hour: Int, minute: Int, in calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }
}
