//
//  ReminderTime.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// A time of day with no date and no zone — "08:00", wherever the phone is.
///
/// **Not a `Date`.** A stored instant moves with the time zone, so a morning reminder set in
/// London would fire at 03:00 after a flight to New York. An hour and a minute are applied to
/// each day as it comes, in the zone the phone is in then, the same reasoning as `ScheduleDay`.
public struct ReminderTime: Codable, Hashable, Sendable {
    public let hour: Int
    public let minute: Int

    public init(hour: Int, minute: Int) {
        self.hour = min(max(hour, 0), 23)
        self.minute = min(max(minute, 0), 59)
    }

    public static let morning = ReminderTime(hour: 8, minute: 0)
    public static let evening = ReminderTime(hour: 20, minute: 0)

    /// This time on `day`, in `calendar`'s zone. On the one night a year a clock skips forward
    /// past it, `Calendar` moves it on to the first moment that exists.
    func date(on day: ScheduleDay, calendar: Calendar) -> Date {
        let start = day.date(calendar: calendar)
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: start) ?? start
    }
}
