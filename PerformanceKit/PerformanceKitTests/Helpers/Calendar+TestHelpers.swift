//
//  Calendar+TestHelpers.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

extension Calendar {

    /// Gregorian in UTC, so day arithmetic in tests does not move with the
    /// machine's time zone.
    static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()
}
