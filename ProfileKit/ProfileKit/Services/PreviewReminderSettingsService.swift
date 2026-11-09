//
//  PreviewReminderSettingsService.swift
//  ProfileKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// Reminder settings for previews: held in memory, permission as given.
@MainActor
public final class PreviewReminderSettingsService: ReminderSettingsService {

    private var settings: ProfileReminderSettings
    private var status: ProfileReminderPermission

    public init(
        settings: ProfileReminderSettings = ProfileReminderSettings(
            checkIn: ProfileReminderSetting(isOn: true, hour: 8, minute: 0, weekdays: Set(ProfileWeekday.allCases)),
            dayRating: ProfileReminderSetting(isOn: false, hour: 20, minute: 0, weekdays: Set(ProfileWeekday.allCases))
        ),
        status: ProfileReminderPermission = .allowed
    ) {
        self.settings = settings
        self.status = status
    }

    public func loadSettings() -> ProfileReminderSettings { settings }
    public func save(_ settings: ProfileReminderSettings) { self.settings = settings }
    public func permission() async -> ProfileReminderPermission { status }
    public func requestPermission() async -> Bool {
        if status == .notAsked { status = .allowed }
        return status == .allowed
    }
}
