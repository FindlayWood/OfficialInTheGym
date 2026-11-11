//
//  PlannedReminder.swift
//  MyDayKit
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation

/// One notification the planner wants pending: what, when, and what it says.
///
/// **The identifier is derived from the kind and the day** — `reminder.checkIn.2026-11-10` —
/// so planning twice produces the same request rather than a second one, and a day's reminder
/// can be cancelled by name once it is no longer needed.
public struct PlannedReminder: Equatable, Sendable {
    public let kind: ReminderKind
    public let day: ScheduleDay
    public let fireDate: Date
    public let title: String
    public let body: String

    public var identifier: String {
        Self.identifier(for: kind, on: day)
    }

    static func identifier(for kind: ReminderKind, on day: ScheduleDay) -> String {
        "\(ReminderKind.identifierPrefix)\(kind.rawValue).\(day.key)"
    }
}
