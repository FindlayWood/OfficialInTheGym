//
//  ProfileReminderSetting.swift
//  ProfileKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// One reminder as the Reminders screen edits it: on or off, a time of day, and the weekdays.
///
/// **An hour and a minute, never a `Date`** — a stored instant moves with the time zone, and
/// "08:00" should stay 08:00 after a flight. MyDayKit's `ReminderTime` holds it the same way.
public struct ProfileReminderSetting: Equatable, Sendable {
    public var isOn: Bool
    public var hour: Int
    public var minute: Int
    public var weekdays: Set<ProfileWeekday>

    public init(isOn: Bool, hour: Int, minute: Int, weekdays: Set<ProfileWeekday>) {
        self.isOn = isOn
        self.hour = hour
        self.minute = minute
        self.weekdays = weekdays
    }
}
