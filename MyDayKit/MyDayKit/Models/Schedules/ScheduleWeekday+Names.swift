//
//  ScheduleWeekday+Names.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation

extension ScheduleWeekday {

    /// The chip's letter. Tuesday and Thursday share one, as they do on any calendar, so the chip
    /// also carries `fullName` for VoiceOver.
    var initial: String {
        String(shortName.prefix(1))
    }

    var shortName: String {
        String(fullName.prefix(3))
    }

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
}
