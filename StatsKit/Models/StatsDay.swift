//
//  StatsDay.swift
//  StatsKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

// MARK: - StatsDay
/// The one definition of a "day" in this module.
///
/// `DailyTotal.id` and `ExerciseDailyStats.id` are `yyyy-MM-dd` document ids
/// minted server-side in **UTC**, and `DateFormatter.yyyyMMdd` reads them back
/// in UTC. Every piece of day arithmetic here — the streak, the activity dots,
/// the rolling ACWR windows — steps days to build those same keys, so it has to
/// step them in the calendar the keys were written in.
///
/// Stepping with `Calendar.current` instead means that for any user east of GMT
/// the key built for "now" is *yesterday's* document for part of every day: the
/// streak breaks, and every rolling window is silently shifted by one.
///
/// **Do not reach for `Calendar.current` on the stats path.** If a screen needs
/// to show a date to the user, format it in their locale at the point of
/// display — but look it up through here.
public enum StatsDay {

    /// The calendar every stats day key is built in. Matches the time zone of
    /// `DateFormatter.yyyyMMdd`; the two must not drift apart.
    public static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    /// The `yyyy-MM-dd` document id for a date.
    public static func key(for date: Date) -> String {
        DateFormatter.yyyyMMdd.string(from: date)
    }

    /// `daysAgo` days before `date`.
    public static func date(daysAgo: Int, from date: Date = .now) -> Date {
        calendar.date(byAdding: .day, value: -daysAgo, to: date)!
    }

    /// The `yyyy-MM-dd` document id for `daysAgo` days before `date`.
    public static func key(daysAgo: Int, from date: Date = .now) -> String {
        key(for: self.date(daysAgo: daysAgo, from: date))
    }

    /// Start of the day containing `date`.
    ///
    /// This is the cutoff a Firestore range query wants: the loaders compare
    /// against a stored timestamp rather than a key, and a cutoff taken at the
    /// current time of day would drop the oldest day's document for most of it.
    public static func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    /// Start of the day `daysAgo` days before `date` — the cutoff for a rolling
    /// window of `daysAgo` days.
    public static func startOfDay(daysAgo: Int, from date: Date = .now) -> Date {
        startOfDay(for: self.date(daysAgo: daysAgo, from: date))
    }
}
