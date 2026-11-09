//
//  ScheduleDay+Display.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation

extension ScheduleDay {

    /// "Tue 10 Nov". Read in UTC, the zone `date(calendar:)` is given here, because a `ScheduleDay`
    /// has no zone of its own and this only has to name the day it already is.
    var displayText: String {
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(secondsFromGMT: 0)!

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = utc.timeZone
        formatter.dateFormat = "EEE d MMM"
        return formatter.string(from: date(calendar: utc))
    }

    /// `displayText`, with today and tomorrow in words. A schedule's next day is usually one of them.
    func displayText(relativeTo today: ScheduleDay) -> String {
        if self == today { return "Today" }
        if self == today.adding(days: 1) { return "Tomorrow" }
        return displayText
    }
}
