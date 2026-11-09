//
//  ProfileWeekday.swift
//  ProfileKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// A day of the week for a reminder, **Monday first**, raw value 0 to 6 — the same numbering as
/// MyDayKit's `ScheduleWeekday`, which the composition root maps it to. ProfileKit imports no
/// other framework, so it carries its own.
public enum ProfileWeekday: Int, CaseIterable, Hashable, Sendable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var fullName: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }

    /// The chip's letter. Tuesday and Thursday share one, so the chip also carries `fullName`
    /// for VoiceOver.
    var initial: String {
        String(fullName.prefix(1))
    }
}
