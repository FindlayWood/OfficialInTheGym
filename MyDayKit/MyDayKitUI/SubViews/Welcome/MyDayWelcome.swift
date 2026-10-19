//
//  MyDayWelcome.swift
//  MyDayKit
//
//  Created by Findlay Wood on 19/10/2026.
//

import Foundation

/// Who signed up, and when — all MyDay needs to mark the day someone joined.
///
/// **Derived from the account, never stored.** The day the welcome card shows is
/// worked out from `Users.createdDate` on every render, so there is no "seen it"
/// flag to keep, sync or lose on reinstall: the card is there on signup day on
/// every device, and on every later visit to that day it is the quieter
/// `MyDayJoinedRow`. A flag would make the card something to get rid of; the
/// date makes it a landmark in the user's own history.
///
/// The day is judged in **`Calendar.current`**, the calendar MyDay's date strip
/// and day files use — not `StatsDay`'s UTC one. A user east of GMT signing up
/// just after midnight would otherwise find the card on yesterday.
public struct MyDayWelcome {
    public let name: String
    public let signupDate: Date

    public init(name: String, signupDate: Date) {
        self.name = name
        self.signupDate = signupDate
    }

    func isSignupDay(_ date: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(date, inSameDayAs: signupDate)
    }

    /// Whole days from the signup day to `date`, never negative — the date
    /// strip's floor. A signup date after `date` (a device clock behind the
    /// server's) is 0, so the strip still has today rather than no past at all.
    func daysSinceSignup(to date: Date, calendar: Calendar = .current) -> Int {
        let joined = calendar.startOfDay(for: signupDate)
        let day = calendar.startOfDay(for: date)
        return max(calendar.dateComponents([.day], from: joined, to: day).day ?? 0, 0)
    }

    /// The first word of the display name, or `nil` when there is none — the card
    /// then greets without a name rather than with an empty one.
    var firstName: String? {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .first
            .map(String.init)
    }
}
