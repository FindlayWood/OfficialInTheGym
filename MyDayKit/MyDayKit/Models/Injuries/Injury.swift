//
//  Injury.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// Something that hurts, from the day it started until the user says it has cleared, with a
/// check-in for every day they rated it. See `READINESS_PLAN.md` part 3.
///
/// - **It ends when the user says so** (`resolvedOn`). Never inferred from pain reaching 0:
///   people feel fine and still protect it, and "no pain" is not "back to normal".
/// - **Removing is for mistakes** (`removedAt`), not recovery, and it never deletes. Copies merge
///   by id, so a deleted document would come back from the other copy — the same reason a
///   schedule is stopped rather than deleted. A removed injury is read by nothing.
/// - **Days are `ScheduleDay`s** — a day with no time or zone, judged in `Calendar.current` as
///   MyDay's strip is. A check-in saved at 23:30 belongs to the day the user was living.
/// - **Private, always.** Never on `Profiles`, never in DISCOVER.
public struct Injury: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public var region: InjuryRegion
    /// `nil` for a region with no side (`InjuryRegion.hasSide`).
    public var side: InjurySide?
    public var startedOn: ScheduleDay
    public var resolvedOn: ScheduleDay?
    public var note: String?
    /// Keyed by `ScheduleDay.key`, so one per day.
    public var checkIns: [String: InjuryCheckIn]
    public let createdAt: Date
    public var updatedAt: Date
    public var removedAt: Date?

    public init(
        id: String = UUID().uuidString,
        region: InjuryRegion,
        side: InjurySide?,
        startedOn: ScheduleDay,
        resolvedOn: ScheduleDay? = nil,
        note: String? = nil,
        checkIns: [String: InjuryCheckIn] = [:],
        createdAt: Date,
        updatedAt: Date,
        removedAt: Date? = nil
    ) {
        self.id = id
        self.region = region
        self.side = region.hasSide ? side : nil
        self.startedOn = startedOn
        self.resolvedOn = resolvedOn
        self.note = note
        self.checkIns = checkIns
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.removedAt = removedAt
    }

    /// "Left hamstring", "Both knees", "Lower back".
    public var title: String {
        guard region.hasSide, let side else {
            return region.name.prefix(1).uppercased() + region.name.dropFirst()
        }
        switch side {
        case .both: return "Both \(region.pluralName)"
        case .left, .right: return "\(side.title) \(region.name)"
        }
    }

    /// On MyDay on `day`: started by then, not yet cleared, not removed. An injury cleared today
    /// stops showing today — saying so is the last thing the user did with it.
    public func isActive(on day: ScheduleDay) -> Bool {
        guard removedAt == nil, startedOn <= day else { return false }
        guard let resolvedOn else { return true }
        return day < resolvedOn
    }

    public func checkIn(on day: ScheduleDay) -> InjuryCheckIn? {
        checkIns[day.key]
    }

    /// The most recent check-in before `day`, to pre-fill today's so an unchanged day is one tap.
    func latestCheckIn(before day: ScheduleDay) -> InjuryCheckIn? {
        checkIns
            .compactMap { key, checkIn in ScheduleDay(key: key).map { ($0, checkIn) } }
            .filter { $0.0 < day }
            .max { $0.0 < $1.0 }?
            .1
    }

    /// Days since it started, counting the first as day 1: "Day 6".
    func dayNumber(on day: ScheduleDay) -> Int {
        var count = 1
        var current = startedOn
        while current < day {
            current = current.adding(days: 1)
            count += 1
        }
        return count
    }
}
