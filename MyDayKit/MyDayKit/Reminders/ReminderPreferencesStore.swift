//
//  ReminderPreferencesStore.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// Where the user's reminder settings are kept. **On the device, per user, by decision**
/// (`READINESS_PLAN.md`): a notification only ever fires on the phone that scheduled it, so a
/// setting synced to a second phone would describe reminders that phone has never planned.
/// A new phone starts with every reminder off.
public protocol ReminderPreferencesStore {
    func load() -> ReminderPreferences
    func save(_ preferences: ReminderPreferences)
}
