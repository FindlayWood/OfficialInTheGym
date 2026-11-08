//
//  ScheduleDay.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation

/// A day on the calendar with no time and no zone — what a schedule means by "the 10th".
///
/// **Stored as a `yyyy-MM-dd` key, never a `Date`.** A `Date` is an instant, so one saved for a
/// Tuesday lands on Monday or Wednesday once the user is in another time zone. The key says the
/// 10th wherever it is read.
///
/// **A `Date` becomes a day in the user's own zone, as MyDay's date strip judges it, not
/// `StatsDay`'s UTC.** "Tuesday" means the user's Tuesday. From then on everything is arithmetic
/// on a plain day number, which has no clock in it, so a clock change cannot shift a day or a
/// week. Stepping through dates in a real zone is how that goes wrong: some days there are 23
/// hours long.
///
/// **The Gregorian calendar is used whatever the device's calendar is.** Only the device's zone is
/// taken from it. On a Buddhist calendar the year would otherwise read 2569, and the stored key
/// would name a different day from the one every other device reads.
public struct ScheduleDay: Hashable, Comparable, Sendable {

    private static let secondsPerDay = 86_400.0

    /// The calendar the day number is counted in. Pinned to UTC, where every day is 24 hours, so
    /// the number is exact. It says nothing about which day it is for the user.
    private static let countingCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    /// Whole days since 1 January 1970.
    private let dayNumber: Int

    private init(dayNumber: Int) {
        self.dayNumber = dayNumber
    }

    private init(components: DateComponents) {
        let date = Self.countingCalendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
        self.init(dayNumber: Int((date.timeIntervalSince1970 / Self.secondsPerDay).rounded(.down)))
    }

    /// The day `date` falls on in `calendar`'s time zone.
    public init(_ date: Date, calendar: Calendar = .current) {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        self.init(components: gregorian.dateComponents([.year, .month, .day], from: date))
    }

    /// `nil` unless `key` is a real date written exactly as `yyyy-MM-dd`. Reading it back and
    /// comparing is what rejects the 30th of February, which `Calendar` would quietly roll into
    /// March.
    public init?(key: String) {
        let parts = key.split(separator: "-", omittingEmptySubsequences: false).map { Int($0) }
        guard parts.count == 3, let year = parts[0], let month = parts[1], let day = parts[2] else {
            return nil
        }
        self.init(components: DateComponents(year: year, month: month, day: day))
        guard self.key == key else { return nil }
    }

    /// The form this day is stored in.
    public var key: String {
        let date = Date(timeIntervalSince1970: Double(dayNumber) * Self.secondsPerDay)
        let parts = Self.countingCalendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    /// The start of this day in `calendar`'s time zone, for showing it or choosing it on screen.
    public func date(calendar: Calendar = .current) -> Date {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        let utcDate = Date(timeIntervalSince1970: Double(dayNumber) * Self.secondsPerDay)
        let parts = Self.countingCalendar.dateComponents([.year, .month, .day], from: utcDate)
        return gregorian.date(from: parts) ?? utcDate
    }

    public var weekday: ScheduleWeekday {
        ScheduleWeekday.allCases[mondayOffset]
    }

    public func adding(days: Int) -> ScheduleDay {
        ScheduleDay(dayNumber: dayNumber + days)
    }

    /// How many Mondays lie between the week holding `start` and the week holding this day.
    /// Counted Monday to Monday, so where each day falls inside its week makes no difference.
    func weeks(sinceWeekOf start: ScheduleDay) -> Int {
        (startOfWeekNumber - start.startOfWeekNumber) / 7
    }

    /// 1 January 1970 was a Thursday, three days after a Monday. Wrapped rather than a plain `%`,
    /// which goes negative for days before it.
    private var mondayOffset: Int {
        ((dayNumber + 3) % 7 + 7) % 7
    }

    private var startOfWeekNumber: Int {
        dayNumber - mondayOffset
    }

    public static func < (lhs: ScheduleDay, rhs: ScheduleDay) -> Bool {
        lhs.dayNumber < rhs.dayNumber
    }
}

extension ScheduleDay: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let key = try container.decode(String.self)
        guard let day = ScheduleDay(key: key) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "\(key) is not a yyyy-MM-dd day"
            )
        }
        self = day
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(key)
    }
}
