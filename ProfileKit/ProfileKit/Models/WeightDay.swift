//
//  WeightDay.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// The one definition of a weight entry's day: a `yyyy-MM-dd` key and its
/// midnight, both in **UTC**.
///
/// UTC because the server already keys this collection that way.
/// `createAccount` names the signup entry with `dateKey()`, which is UTC, and
/// a device-calendar key would put the first log of the day on a different
/// document from the signup entry for anyone east of GMT. This is the same
/// reasoning as StatsKit's `StatsDay`, which ProfileKit cannot import. **Keep
/// the two in step.**
///
/// Shown to the user through `displayFormatter`, also pinned to UTC, so the
/// day printed is the day in the key, not the day before.
enum WeightDay {

    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    private static let keyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = calendar.timeZone
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static func key(for date: Date) -> String {
        keyFormatter.string(from: date)
    }

    static func midnight(of date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func entry(kilograms: Double, unit: ProfileWeightUnit, on date: Date) -> WeightEntry {
        WeightEntry(id: key(for: date), date: midnight(of: date), weightKilograms: kilograms, unit: unit)
    }
}
