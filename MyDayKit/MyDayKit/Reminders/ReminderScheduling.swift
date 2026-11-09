//
//  ReminderScheduling.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// Makes the pending reminders exactly `reminders`. Implemented in the composition root over
/// `UNUserNotificationCenter`.
///
/// **A replace, not an add.** Whatever is pending under `ReminderKind.identifierPrefix` and not
/// in the list goes — that removal is how a check-in cancels its own reminder. Anything outside
/// the prefix (the trial reminder) is never touched.
public protocol ReminderScheduling: Sendable {
    func replaceReminders(with reminders: [PlannedReminder]) async
}
