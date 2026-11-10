//
//  StatsInjury.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// An injury as STATS reads it: where, from when to when, and how it felt each day. Built by
/// the composition root from MyDayKit's `Injury`, which is the one that is stored; this is
/// read-only.
///
/// **Days are `yyyy-MM-dd` keys, read as `StatsDay` keys.** MyDay judges an injury's days in the
/// phone's calendar and `DailyTotal`s are keyed in UTC, so for someone far from GMT the two can
/// be a day apart around midnight. Accepted, as `READINESS_PLAN.md` records: the page reads
/// weeks of load, and a day either side does not change what a fortnight says.
public struct StatsInjury: Identifiable, Hashable, Sendable {

    public struct CheckIn: Hashable, Sendable {
        public let pain: Int
        public let impact: StatsInjuryImpact

        public init(pain: Int, impact: StatsInjuryImpact) {
            self.pain = pain
            self.impact = impact
        }
    }

    public let id: String
    /// "Left hamstring" — worded by MyDayKit, which owns regions and sides.
    public let title: String
    public let startedOn: String
    /// The day it was marked cleared, or `nil` while it is current.
    public let resolvedOn: String?
    public let checkIns: [String: CheckIn]

    public init(id: String, title: String, startedOn: String, resolvedOn: String?, checkIns: [String: CheckIn]) {
        self.id = id
        self.title = title
        self.startedOn = startedOn
        self.resolvedOn = resolvedOn
        self.checkIns = checkIns
    }

    public var isCurrent: Bool { resolvedOn == nil }

    var startDate: Date? { DateFormatter.yyyyMMdd.date(from: startedOn) }

    /// The last day it was carrying on: the day before it cleared, or today. Never before the
    /// start.
    func lastDay(today: Date = .now) -> Date? {
        guard let start = startDate else { return nil }
        let end: Date
        if let resolvedOn, let resolved = DateFormatter.yyyyMMdd.date(from: resolvedOn) {
            end = StatsDay.date(daysAgo: 1, from: resolved)
        } else {
            end = StatsDay.startOfDay(for: today)
        }
        return max(start, end)
    }

    /// Every day it lasted, oldest first, as keys.
    func dayKeys(today: Date = .now) -> [String] {
        guard let start = startDate, let end = lastDay(today: today) else { return [] }
        let count = (StatsDay.calendar.dateComponents([.day], from: start, to: end).day ?? 0) + 1
        return (0..<count).reversed().map { StatsDay.key(daysAgo: $0, from: end) }
    }

    /// Check-ins oldest first.
    var orderedCheckIns: [(day: String, checkIn: CheckIn)] {
        checkIns.sorted { $0.key < $1.key }.map { ($0.key, $0.value) }
    }

    var latestCheckIn: CheckIn? {
        orderedCheckIns.last?.checkIn
    }
}
