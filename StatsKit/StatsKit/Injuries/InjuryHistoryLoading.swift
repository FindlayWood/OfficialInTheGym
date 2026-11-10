//
//  InjuryHistoryLoading.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// Every injury the user has logged, current and cleared, newest start first. Implemented in
/// the composition root over MyDay's local-first injury store, so an injury rated with no
/// signal is already here. Removed injuries (added by mistake) are never delivered.
public protocol InjuryHistoryLoading {
    func loadInjuries() async throws -> [StatsInjury]
}

/// Nothing logged — the default for routers built without injuries, and for previews that
/// should show the home without the section.
public struct EmptyInjuryHistoryLoader: InjuryHistoryLoading {
    public init() {}
    public func loadInjuries() async throws -> [StatsInjury] { [] }
}

/// One current and one cleared injury, dated relative to today so they line up with
/// `MockDailyTotalsProvider`'s generated history.
public struct PreviewInjuryHistoryLoader: InjuryHistoryLoading, @unchecked Sendable {
    public init() {}

    public func loadInjuries() async throws -> [StatsInjury] {
        Self.samples
    }

    public static var samples: [StatsInjury] {
        var current: [String: StatsInjury.CheckIn] = [:]
        for (offset, pain) in [6, 5, 5, 4, 3, 3].enumerated() {
            current[StatsDay.key(daysAgo: 5 - offset)] = .init(pain: pain, impact: pain > 4 ? .modified : .none)
        }
        var cleared: [String: StatsInjury.CheckIn] = [:]
        for (offset, pain) in [8, 7, 6, 4, 2, 1].enumerated() {
            cleared[StatsDay.key(daysAgo: 50 - offset * 2)] = .init(pain: pain, impact: pain > 6 ? .stopped : .modified)
        }
        return [
            StatsInjury(id: "knee", title: "Right knee", startedOn: StatsDay.key(daysAgo: 5), resolvedOn: nil, checkIns: current),
            StatsInjury(id: "hamstring", title: "Left hamstring", startedOn: StatsDay.key(daysAgo: 50), resolvedOn: StatsDay.key(daysAgo: 38), checkIns: cleared)
        ]
    }
}
