//
//  ReadinessProviding.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// The user's `ReadinessDay`s over the last `StatsHistoryWindow.days`, oldest first.
/// Implemented in the composition root over `Users/{uid}/Readiness`.
public protocol ReadinessProviding {
    func fetchReadiness() async throws -> [ReadinessDay]
}

/// No check-ins — the default for routers built without readiness.
public struct EmptyReadinessProvider: ReadinessProviding {
    public init() {}
    public func fetchReadiness() async throws -> [ReadinessDay] { [] }
}

/// Twelve weeks of check-ins for previews, with a dip and missed days so the average line and
/// its gaps both show. Fixed, not random, so a preview reads the same every time.
public struct MockReadinessProvider: ReadinessProviding, @unchecked Sendable {
    public init() {}

    public func fetchReadiness() async throws -> [ReadinessDay] { Self.samples }

    public static var samples: [ReadinessDay] {
        (0..<84).reversed().compactMap { daysAgo -> ReadinessDay? in
            guard daysAgo % 6 != 3 else { return nil }
            let dip = (20...30).contains(daysAgo) ? -1 : 0
            let sleep = min(5, max(1, 3 + (daysAgo % 3 == 0 ? 1 : 0) + dip))
            let body = min(5, max(1, 4 - (daysAgo % 4 == 0 ? 1 : 0) + dip))
            let focus = min(5, max(1, 4 + dip))
            let mood = min(5, max(1, 3 + (daysAgo % 5 == 0 ? 1 : 0)))
            return ReadinessDay(
                id: StatsDay.key(daysAgo: daysAgo),
                sleep: sleep, body: body, focus: focus, mood: mood,
                readiness: Double(sleep + body + focus + mood) / 20,
                dayRPE: daysAgo % 2 == 0 ? 5 + daysAgo % 4 : nil
            )
        }
    }
}
