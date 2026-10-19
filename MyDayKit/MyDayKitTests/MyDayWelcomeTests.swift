//
//  MyDayWelcomeTests.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 19/10/2026.
//

import XCTest
@testable import MyDayKit

final class MyDayWelcomeTests: XCTestCase {

    func test_isSignupDay_deliversTrueLaterTheSameDay() {
        let sut = MyDayWelcome(name: "Findlay", signupDate: date(hour: 0, minute: 30))

        XCTAssertTrue(sut.isSignupDay(date(hour: 23, minute: 59), calendar: tokyo))
    }

    func test_isSignupDay_deliversFalseOnTheNextDay() {
        let sut = MyDayWelcome(name: "Findlay", signupDate: date(hour: 23, minute: 30))

        XCTAssertFalse(sut.isSignupDay(date(day: 2, hour: 0, minute: 10), calendar: tokyo))
    }

    // The day is the user's own, as MyDay's date strip draws it. Judged in UTC, a
    // signup at 00:30 in Tokyo falls on the previous day, and the card would land
    // on yesterday.
    func test_isSignupDay_judgesTheDayInTheCalendarGivenNotUTC() {
        let sut = MyDayWelcome(name: "Findlay", signupDate: date(hour: 0, minute: 30))

        XCTAssertTrue(sut.isSignupDay(date(hour: 12, minute: 0), calendar: tokyo))
        XCTAssertFalse(sut.isSignupDay(date(hour: 12, minute: 0), calendar: utc))
    }

    // Counted in whole calendar days: 23:30 to 00:10 the next day is one day, not none.
    func test_daysSinceSignup_deliversCalendarDaysNotElapsedTime() {
        let sut = MyDayWelcome(name: "Findlay", signupDate: date(hour: 23, minute: 30))

        XCTAssertEqual(sut.daysSinceSignup(to: date(day: 2, hour: 0, minute: 10), calendar: tokyo), 1)
        XCTAssertEqual(sut.daysSinceSignup(to: date(hour: 23, minute: 45), calendar: tokyo), 0)
    }

    // A signup stamped after the device's today would otherwise floor the strip
    // below today and leave it with no past day at all.
    func test_daysSinceSignup_deliversZeroWhenSignupIsAfterTheDate() {
        let sut = MyDayWelcome(name: "Findlay", signupDate: date(day: 2, hour: 9, minute: 0))

        XCTAssertEqual(sut.daysSinceSignup(to: fixedDate, calendar: tokyo), 0)
    }

    func test_firstName_deliversFirstWordOfDisplayName() {
        let sut = MyDayWelcome(name: "  Findlay Wood ", signupDate: fixedDate)

        XCTAssertEqual(sut.firstName, "Findlay")
    }

    // An empty name greets without one, never "Welcome to INTHEGYM, ".
    func test_firstName_deliversNilForBlankName() {
        let sut = MyDayWelcome(name: "   ", signupDate: fixedDate)

        XCTAssertNil(sut.firstName)
    }

    // MARK: - Helpers

    private var fixedDate: Date { date(hour: 9, minute: 0) }

    private var tokyo: Calendar { calendar(TimeZone(identifier: "Asia/Tokyo")!) }

    private var utc: Calendar { calendar(TimeZone(identifier: "UTC")!) }

    private func calendar(_ timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    /// A time on 1 or 2 June 2026, Tokyo.
    private func date(day: Int = 1, hour: Int, minute: Int) -> Date {
        tokyo.date(from: DateComponents(year: 2026, month: 6, day: day, hour: hour, minute: minute))!
    }
}
