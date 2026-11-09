//
//  ScheduleTextTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 08/11/2026.
//

import XCTest
@testable import MyDayKit

final class ScheduleTextTests: XCTestCase {

    func test_summary_deliversTheDateOfAOneOff() {
        XCTAssertEqual(ScheduleRecurrence.once(day: .fixture("2026-11-10")).summary, "Tue 10 Nov")
    }

    // `Set` has no order, so without sorting the same schedule could read differently between launches.
    func test_summary_listsWeekdaysMondayFirst() {
        let sut = ScheduleRecurrence.weekly(weekdays: [.sunday, .thursday, .monday], start: start)

        XCTAssertEqual(sut.summary, "Every Mon, Thu, Sun")
    }

    func test_summary_saysEveryDayWhenAllSevenArePicked() {
        let sut = ScheduleRecurrence.weekly(weekdays: Set(ScheduleWeekday.allCases), start: start)

        XCTAssertEqual(sut.summary, "Every day")
    }

    func test_summary_namesTheFrequencyOfEveryTwoWeeks() {
        let sut = ScheduleRecurrence.everyTwoWeeks(weekdays: [.tuesday, .friday], start: start)

        XCTAssertEqual(sut.summary, "Every 2 weeks on Tue, Fri")
    }

    func test_displayText_usesWordsForTodayAndTomorrow() {
        let today = ScheduleDay.fixture("2026-11-10")

        XCTAssertEqual(today.displayText(relativeTo: today), "Today")
        XCTAssertEqual(today.adding(days: 1).displayText(relativeTo: today), "Tomorrow")
        XCTAssertEqual(today.adding(days: 2).displayText(relativeTo: today), "Thu 12 Nov")
    }

    // MARK: - Helpers

    private let start = ScheduleDay.fixture("2026-11-09")
}
