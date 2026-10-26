//
//  UserDayKey.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// The one definition of a `UserDays/{uid}_{yyyy-MM-dd}` document — the
/// server's per-person, per-day analytics record (`functions/src/Analytics/
/// UserDays.ts` in InTheGym-CloudFunctions).
///
/// **The day is the UTC date**, as the server keys it and as `StatsDay` and
/// `DailyTotals` do. A device-calendar date would put a late-evening open in
/// the wrong document for anyone east of GMT. The Firestore rule accepts a
/// day either side of the server's own clock, so a phone with a wrong clock
/// is still recorded, just not trusted beyond that.
enum UserDayKey {

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// The UTC day key for a moment.
    static func day(for date: Date = .now) -> String {
        formatter.string(from: date)
    }

    /// The document path for a person's day.
    static func path(userId: String, day: String) -> String {
        "UserDays/\(userId)_\(day)"
    }
}
