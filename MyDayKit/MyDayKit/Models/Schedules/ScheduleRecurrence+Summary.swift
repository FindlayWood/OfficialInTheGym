//
//  ScheduleRecurrence+Summary.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation

extension ScheduleRecurrence {

    /// One line saying when this falls: "Tue 10 Nov", "Every Tue, Thu", "Every day" or "Every 2
    /// weeks on Tue". Monday first whatever order the days were picked in, since `Set` has no order
    /// of its own and the same schedule would otherwise read differently between launches.
    var summary: String {
        switch self {
        case .once(let day):
            return day.displayText
        case .weekly(let weekdays, _):
            if weekdays.count == ScheduleWeekday.allCases.count { return "Every day" }
            return "Every \(Self.names(of: weekdays))"
        case .everyTwoWeeks(let weekdays, _):
            return "Every 2 weeks on \(Self.names(of: weekdays))"
        }
    }

    private static func names(of weekdays: Set<ScheduleWeekday>) -> String {
        ScheduleWeekday.allCases
            .filter(weekdays.contains)
            .map(\.shortName)
            .joined(separator: ", ")
    }
}
