//
//  ScheduleRecurrence.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation

/// Which days a schedule falls on. **This is the one definition of that** — the card on MyDay and
/// the "Next: Tue 10 Nov" line on the schedule sheet both read it, so what the sheet promises is
/// what the day shows.
///
/// A repeat never falls before `start`, even on a weekday it names. "Every Tuesday" saved on a
/// Thursday begins next week, and on an every-two-weeks schedule that week may be an off week.
///
/// Every two weeks counts from the week holding `start`: that week is on, the next is off. The
/// weekdays alone cannot say which Tuesdays are meant, so `start` is what decides.
///
/// A repeat with no weekdays never falls on any day. The sheet will not save one, and a damaged
/// document then draws nothing rather than a card on every day.
public enum ScheduleRecurrence: Codable, Equatable, Sendable {
    case once(day: ScheduleDay)
    case weekly(weekdays: Set<ScheduleWeekday>, start: ScheduleDay)
    case everyTwoWeeks(weekdays: Set<ScheduleWeekday>, start: ScheduleDay)

    public func occurs(on day: ScheduleDay) -> Bool {
        switch self {
        case .once(let once):
            return day == once
        case .weekly(let weekdays, let start):
            return day >= start && weekdays.contains(day.weekday)
        case .everyTwoWeeks(let weekdays, let start):
            return day >= start
                && weekdays.contains(day.weekday)
                && day.weeks(sinceWeekOf: start) % 2 == 0
        }
    }

    /// The first day this falls on, from `day` onwards and including it, so a schedule due today
    /// reads as today. `nil` when it will never fall again, which is a finished one-off.
    public func nextOccurrence(onOrAfter day: ScheduleDay) -> ScheduleDay? {
        let first: ScheduleDay
        switch self {
        case .once(let once):
            return once >= day ? once : nil
        case .weekly(_, let start), .everyTwoWeeks(_, let start):
            first = max(day, start)
        }
        // Any fourteen days in a row hold every weekday of an on week, so a repeat that can fall
        // at all falls within them.
        return (0..<14)
            .lazy
            .map { first.adding(days: $0) }
            .first { occurs(on: $0) }
    }
}
