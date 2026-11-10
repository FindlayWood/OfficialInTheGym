//
//  InjuryDayFormat.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// An injury day key shown to the user — "8 Nov". Parsed and formatted in UTC, the zone the key
/// is read in, so the label is the day the key names and never the one either side.
enum InjuryDayFormat {

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d MMM")
        formatter.timeZone = StatsDay.calendar.timeZone
        return formatter
    }()

    static func short(_ key: String) -> String {
        DateFormatter.yyyyMMdd.date(from: key).map(formatter.string(from:)) ?? key
    }

    /// "Since 8 Nov · day 3" or "1 Nov – 12 Nov · 11 days".
    static func span(of injury: StatsInjury, today: Date = .now) -> String {
        let days = injury.dayKeys(today: today).count
        if let resolvedOn = injury.resolvedOn {
            return "\(short(injury.startedOn)) – \(short(resolvedOn)) · \(days) \(days == 1 ? "day" : "days")"
        }
        return "Since \(short(injury.startedOn)) · day \(days)"
    }
}
