//
//  ReminderKind.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// What a reminder asks the user to do. See `READINESS_PLAN.md` part 1.
///
/// **The raw value is stored** (in the preferences and in every pending notification's
/// identifier and `userInfo`), so a case is renamed only with a migration — a pending request
/// whose kind no longer decodes can never be replaced or removed by a re-plan.
public enum ReminderKind: String, CaseIterable, Codable, Sendable {
    case checkIn
    case dayRating

    /// The key a notification's `userInfo` carries the kind under, so a tap can open the step
    /// it was about.
    public static let userInfoKey = "reminderKind"

    /// Every reminder identifier starts with this. It is how the scheduler tells its own
    /// requests from the trial reminder's, which a re-plan must never touch.
    public static let identifierPrefix = "reminder."
}
