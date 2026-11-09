//
//  ProfileReminderSettings.swift
//  ProfileKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// Every reminder setting, as the Reminders screen sees them. The composition root maps this to
/// and from MyDayKit's `ReminderPreferences`, which owns what they mean.
public struct ProfileReminderSettings: Equatable, Sendable {
    public var checkIn: ProfileReminderSetting
    public var dayRating: ProfileReminderSetting

    public init(checkIn: ProfileReminderSetting, dayRating: ProfileReminderSetting) {
        self.checkIn = checkIn
        self.dayRating = dayRating
    }

    subscript(kind: ProfileReminderKind) -> ProfileReminderSetting {
        get {
            switch kind {
            case .checkIn: return checkIn
            case .dayRating: return dayRating
            }
        }
        set {
            switch kind {
            case .checkIn: checkIn = newValue
            case .dayRating: dayRating = newValue
            }
        }
    }

    var hasAnyOn: Bool {
        ProfileReminderKind.allCases.contains { self[$0].isOn }
    }
}
