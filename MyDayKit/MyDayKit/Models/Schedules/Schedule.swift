//
//  Schedule.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation

/// Something the user plans to do, and when. See `SCHEDULES_PLAN.md`.
///
/// **A schedule creates nothing in advance.** MyDay works out what is due while drawing today, and
/// a day entry is written only when the user acts on the card. A plan therefore cannot count
/// towards stats, streaks or markers, which all read what was saved.
///
/// **Stopping sets `stoppedAt`, it never deletes.** Local and remote copies are merged by id with
/// the later `updatedAt` winning, so a schedule deleted on the device would come straight back from
/// the remote copy. Anything already logged from it stays, since that lives on its day.
///
/// **Every field added later must be optional** — the decode warning under *Workout Library
/// Loading* in CLAUDE.md.
public struct Schedule: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public var item: ScheduleItem
    public var recurrence: ScheduleRecurrence
    public let createdAt: Date
    public var updatedAt: Date
    public var stoppedAt: Date?

    public init(
        id: String,
        item: ScheduleItem,
        recurrence: ScheduleRecurrence,
        createdAt: Date,
        updatedAt: Date,
        stoppedAt: Date? = nil
    ) {
        self.id = id
        self.item = item
        self.recurrence = recurrence
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.stoppedAt = stoppedAt
    }

    public func isDue(on day: ScheduleDay) -> Bool {
        stoppedAt == nil && recurrence.occurs(on: day)
    }

    /// The next day this is due, including `day` itself. `nil` for a stopped schedule or a
    /// finished one-off, and that is what takes either off the Scheduled list.
    public func nextDue(onOrAfter day: ScheduleDay) -> ScheduleDay? {
        stoppedAt == nil ? recurrence.nextOccurrence(onOrAfter: day) : nil
    }
}
