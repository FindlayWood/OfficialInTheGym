//
//  UserDefaultsReminderPreferencesStore.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Reminder settings in `UserDefaults`, **one key per user**. The device is shared, so a key
/// without the uid would hand one person's reminders to whoever signs in next — the reason the
/// local template store is scoped by user id.
///
/// Nothing is written until the user changes a setting; an absent key reads as
/// `ReminderPreferences.default`, every reminder off.
struct UserDefaultsReminderPreferencesStore: ReminderPreferencesStore {

    private let defaults: UserDefaults
    private let key: String

    init(userId: String, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.key = "reminderPreferences_\(userId)"
    }

    func load() -> ReminderPreferences {
        guard let data = defaults.data(forKey: key),
              let preferences = try? JSONDecoder().decode(ReminderPreferences.self, from: data) else {
            return .default
        }
        return preferences
    }

    func save(_ preferences: ReminderPreferences) {
        do {
            defaults.set(try JSONEncoder().encode(preferences), forKey: key)
        } catch {
            print("❌ Reminder preferences not saved: \(error)")
        }
    }
}
