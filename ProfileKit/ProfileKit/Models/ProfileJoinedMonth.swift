//
//  ProfileJoinedMonth.swift
//  ProfileKit
//
//  Created by Findlay Wood on 19/10/2026.
//

import Foundation

/// The one definition of how a profile's join date reads: "Joined Oct 2026".
///
/// **Formatted in UTC, because that is the calendar the server cut it in.**
/// `profileProjection` stores midnight UTC on the first of the signup month.
/// Read in the device's zone, anyone west of GMT would see the last day of the
/// month before, and every account would look a month older to them than to
/// everyone else. The signed-in user's own header passes the exact `createdDate`,
/// which in UTC lands in the same month the server chose.
enum ProfileJoinedMonth {

    static func text(for date: Date, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.setLocalizedDateFormatFromTemplate("MMMyyyy")
        return "Joined \(formatter.string(from: date))"
    }
}
