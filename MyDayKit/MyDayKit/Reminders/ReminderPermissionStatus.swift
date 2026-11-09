//
//  ReminderPermissionStatus.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// Whether the system will show the app's notifications. `@frozen`, as `DiscoverSubject` is:
/// MyDayKit builds with library evolution, and without it every `switch` over this in the app
/// needs an `@unknown default`.
@frozen
public enum ReminderPermissionStatus: Equatable, Sendable {
    case allowed
    /// The system prompt has never been shown. iOS shows it once, so it is only asked for when
    /// the user turns a reminder on.
    case notAsked
    /// Turned off in Settings. Only the Settings app can turn it back on.
    case denied
}

/// Notification permission, behind a protocol so nothing in a framework touches
/// `UNUserNotificationCenter`.
public protocol ReminderPermissionAsking: Sendable {
    /// Where permission stands. Never prompts.
    func status() async -> ReminderPermissionStatus
    /// Shows the system prompt if it has never been shown; `true` if reminders can be delivered.
    func request() async -> Bool
}
