//
//  ReminderPreference.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// One reminder's settings: on or off, when, and on which days.
///
/// **Weekdays are Monday-first `ScheduleWeekday`s**, the type schedules store, so "every day
/// but Sunday" means the same thing here as on a schedule whatever the phone's region.
public struct ReminderPreference: Codable, Hashable, Sendable {
    public var isOn: Bool
    public var time: ReminderTime
    public var weekdays: Set<ScheduleWeekday>

    public init(isOn: Bool, time: ReminderTime, weekdays: Set<ScheduleWeekday> = Set(ScheduleWeekday.allCases)) {
        self.isOn = isOn
        self.time = time
        self.weekdays = weekdays
    }

    /// Whether this reminder fires on `day` at all, before asking whether it is still needed.
    /// On with no weekdays picked fires on none, rather than every day.
    func applies(on day: ScheduleDay) -> Bool {
        isOn && weekdays.contains(day.weekday)
    }
}
