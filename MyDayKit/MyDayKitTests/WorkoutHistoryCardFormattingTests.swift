//
//  WorkoutHistoryCardFormattingTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 18/11/2026.
//

import XCTest
@testable import MyDayKit

final class WorkoutHistoryCardFormattingTests: XCTestCase {

    func test_formatDuration_deliversWholeMinutesUnderAnHour() {
        XCTAssertEqual(WorkoutHistoryCard.formatDuration(2_890), "48 min")
    }

    func test_formatDuration_deliversHoursAndPaddedMinutesFromAnHour() {
        XCTAssertEqual(WorkoutHistoryCard.formatDuration(3_900), "1h 05m")
    }

    // "0 min" would read as nothing recorded for a session that did have a time.
    func test_formatDuration_deliversOneMinuteForAnythingShorter() {
        XCTAssertEqual(WorkoutHistoryCard.formatDuration(20), "1 min")
    }

    func test_formatLastDone_deliversTodayAndYesterday() {
        let calendar = fixedCalendar
        let now = Date(timeIntervalSince1970: 1_800_000_000)

        XCTAssertEqual(WorkoutHistoryCard.formatLastDone(now.addingTimeInterval(-60), now: now, calendar: calendar), "today")
        XCTAssertEqual(WorkoutHistoryCard.formatLastDone(now.addingTimeInterval(-86_400), now: now, calendar: calendar), "yesterday")
    }

    func test_formatLastDone_deliversTheDayForAnythingOlder() {
        let calendar = fixedCalendar
        let now = Date(timeIntervalSince1970: 1_800_000_000)

        let text = WorkoutHistoryCard.formatLastDone(now.addingTimeInterval(-5 * 86_400), now: now, calendar: calendar)

        XCTAssertNotEqual(text, "today")
        XCTAssertNotEqual(text, "yesterday")
        XCTAssertFalse(text.isEmpty)
    }

    // MARK: - Helpers

    private var fixedCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }
}
