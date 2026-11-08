//
//  ScheduleWeekday.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation

/// A day of the week on a repeating schedule, **Monday first whatever the device's locale**.
///
/// The raw value is the Monday-based column, the shape `StatsDay.weekdayColumn` uses, and it is
/// what gets stored. Deferring to `Calendar.firstWeekday` would move every stored day with the
/// device's region, so a Tuesday session would become another day after a settings change.
public enum ScheduleWeekday: Int, CaseIterable, Codable, Hashable, Sendable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}
