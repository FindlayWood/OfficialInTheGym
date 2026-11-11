//
//  MyDayReminderSettingsService.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit
import ProfileKit

/// ProfileKit's Settings → Reminders, answered by MyDay's `ReminderManager`. ProfileKit edits
/// the settings and MyDayKit decides what they mean, so this only translates between the two
/// shapes; a save goes straight to the manager, which re-plans.
///
/// **Weekdays map by raw value.** `ProfileWeekday` and `ScheduleWeekday` are both Monday-first,
/// 0 to 6.
@MainActor
final class MyDayReminderSettingsService: ReminderSettingsService {

    private let manager: ReminderManager

    init(manager: ReminderManager) {
        self.manager = manager
    }

    func loadSettings() -> ProfileReminderSettings {
        let preferences = manager.preferences
        return ProfileReminderSettings(
            checkIn: Self.setting(from: preferences.checkIn),
            dayRating: Self.setting(from: preferences.dayRating)
        )
    }

    func save(_ settings: ProfileReminderSettings) {
        manager.update(ReminderPreferences(
            checkIn: Self.preference(from: settings.checkIn),
            dayRating: Self.preference(from: settings.dayRating)
        ))
    }

    func permission() async -> ProfileReminderPermission {
        switch await manager.permissionStatus() {
        case .allowed: return .allowed
        case .notAsked: return .notAsked
        case .denied: return .denied
        }
    }

    func requestPermission() async -> Bool {
        await manager.requestPermission()
    }

    private static func setting(from preference: ReminderPreference) -> ProfileReminderSetting {
        ProfileReminderSetting(
            isOn: preference.isOn,
            hour: preference.time.hour,
            minute: preference.time.minute,
            weekdays: Set(preference.weekdays.compactMap { ProfileWeekday(rawValue: $0.rawValue) })
        )
    }

    private static func preference(from setting: ProfileReminderSetting) -> ReminderPreference {
        ReminderPreference(
            isOn: setting.isOn,
            time: ReminderTime(hour: setting.hour, minute: setting.minute),
            weekdays: Set(setting.weekdays.compactMap { ScheduleWeekday(rawValue: $0.rawValue) })
        )
    }
}
