//
//  ScheduleDayTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 08/11/2026.
//

import XCTest
@testable import MyDayKit

final class ScheduleDayTests: XCTestCase {

    // MARK: - From a date

    // The same instant is Tuesday morning in Tokyo and still Monday evening in Los Angeles. A
    // schedule means the user's own day, so judged in UTC the card would land on the wrong one for
    // part of every day.
    func test_initFromDate_judgesTheDayInTheCalendarsTimeZone() {
        let instant = utcDate("2026-11-10T02:00:00Z")

        XCTAssertEqual(ScheduleDay(instant, calendar: calendar("Asia/Tokyo")).key, "2026-11-10")
        XCTAssertEqual(ScheduleDay(instant, calendar: calendar("America/Los_Angeles")).key, "2026-11-09")
    }

    // Reading the year off a Buddhist calendar would store 2569, naming a different day from the
    // one every other device reads.
    func test_initFromDate_deliversGregorianKeyOnAnotherCalendar() {
        var buddhist = Calendar(identifier: .buddhist)
        buddhist.timeZone = TimeZone(identifier: "Europe/London")!

        let sut = ScheduleDay(utcDate("2026-11-10T12:00:00Z"), calendar: buddhist)

        XCTAssertEqual(sut.key, "2026-11-10")
    }

    func test_dateCalendar_deliversStartOfTheDayInTheCalendarsTimeZone() {
        let tokyo = calendar("Asia/Tokyo")

        let sut = ScheduleDay.fixture("2026-11-10").date(calendar: tokyo)

        XCTAssertEqual(sut, utcDate("2026-11-09T15:00:00Z"))
    }

    // MARK: - Key

    func test_initFromKey_deliversTheSameKeyBack() {
        XCTAssertEqual(ScheduleDay(key: "2028-02-29")?.key, "2028-02-29")
    }

    // `Calendar` would quietly roll the 30th of February into March, and a damaged document would
    // then put its card on a day nobody chose.
    func test_initFromKey_deliversNilForDateThatDoesNotExist() {
        XCTAssertNil(ScheduleDay(key: "2026-02-30"))
        XCTAssertNil(ScheduleDay(key: "2027-02-29"))
        XCTAssertNil(ScheduleDay(key: "2026-13-01"))
    }

    func test_initFromKey_deliversNilForAnythingNotWrittenAsAKey() {
        XCTAssertNil(ScheduleDay(key: "2026-1-5"))
        XCTAssertNil(ScheduleDay(key: "tuesday"))
        XCTAssertNil(ScheduleDay(key: ""))
    }

    // MARK: - Weekday

    func test_weekday_deliversEachDayOfAKnownWeek() {
        let monday = ScheduleDay.fixture("2026-11-09")

        let sut = (0..<7).map { monday.adding(days: $0).weekday }

        XCTAssertEqual(sut, ScheduleWeekday.allCases)
    }

    // A plain `%` goes negative before 1970 and would index outside the week.
    func test_weekday_deliversCorrectDayBeforeTheCountBegins() {
        XCTAssertEqual(ScheduleDay.fixture("1969-12-31").weekday, .wednesday)
    }

    // MARK: - Arithmetic

    func test_adding_crossesAMonthAndYearEnd() {
        XCTAssertEqual(ScheduleDay.fixture("2026-12-31").adding(days: 1).key, "2027-01-01")
    }

    func test_adding_landsOnLeapDay() {
        XCTAssertEqual(ScheduleDay.fixture("2028-02-28").adding(days: 1).key, "2028-02-29")
    }

    func test_weeksSinceWeekOf_ignoresWhereEachDayFallsInItsWeek() {
        let sut = ScheduleDay.fixture("2026-11-16")

        XCTAssertEqual(sut.weeks(sinceWeekOf: .fixture("2026-11-15")), 1)
        XCTAssertEqual(sut.weeks(sinceWeekOf: .fixture("2026-11-09")), 1)
        XCTAssertEqual(sut.weeks(sinceWeekOf: .fixture("2026-11-16")), 0)
    }

    // MARK: - Codable

    func test_encode_deliversThePlainKey() throws {
        let data = try JSONEncoder().encode([ScheduleDay.fixture("2026-11-10")])

        XCTAssertEqual(String(decoding: data, as: UTF8.self), #"["2026-11-10"]"#)
    }

    func test_decode_throwsOnDamagedKey() {
        let data = Data(#"["2026-02-30"]"#.utf8)

        XCTAssertThrowsError(try JSONDecoder().decode([ScheduleDay].self, from: data))
    }

    // MARK: - Helpers

    private func calendar(_ zone: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: zone)!
        return calendar
    }

    private func utcDate(_ iso8601: String) -> Date {
        ISO8601DateFormatter().date(from: iso8601)!
    }
}
