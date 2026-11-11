//
//  ReminderSettingsService.swift
//  ProfileKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// The reminder settings, for Settings → Reminders.
///
/// **ProfileKit only edits them.** What a reminder means — when it fires and when it is skipped —
/// is MyDayKit's (`ReminderPlanner`), and the composition root answers this protocol with
/// MyDay's `ReminderManager`, so a change here re-plans the pending notifications at once.
@MainActor
public protocol ReminderSettingsService: AnyObject {
    func loadSettings() -> ProfileReminderSettings
    /// Saves and re-plans. Called on every change — there is no Save button.
    func save(_ settings: ProfileReminderSettings)
    /// Where permission stands. Never prompts.
    func permission() async -> ProfileReminderPermission
    /// Shows the system prompt if it has never been shown; `true` if reminders can be delivered.
    func requestPermission() async -> Bool
}
