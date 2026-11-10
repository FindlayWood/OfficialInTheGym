//
//  InjuryReportTestHelpers.swift
//  StatsKitTests
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation
@testable import StatsKit

extension StatsInjury {

    static func fixture(
        startedDaysAgo: Int,
        resolvedDaysAgo: Int? = nil,
        from today: Date,
        checkIns: [String: CheckIn] = [:]
    ) -> StatsInjury {
        StatsInjury(
            id: "injury",
            title: "Left hamstring",
            startedOn: StatsDay.key(daysAgo: startedDaysAgo, from: today),
            resolvedOn: resolvedDaysAgo.map { StatsDay.key(daysAgo: $0, from: today) },
            checkIns: checkIns
        )
    }
}

extension DailyTotal {

    static func fixture(
        daysAgo: Int,
        from today: Date,
        volume: Double = 0,
        workload: Double? = nil,
        sets: Int = 0,
        muscleGroupVolumes: [String: Double] = [:]
    ) -> DailyTotal {
        let date = StatsDay.date(daysAgo: daysAgo, from: today)
        return DailyTotal(
            id: StatsDay.key(for: date),
            date: date,
            userID: "user",
            totalSets: sets,
            totalReps: 0,
            totalWeight: 0,
            totalVolume: volume,
            totalTime: 0,
            exerciseSetCounts: [:],
            muscleGroupVolumes: muscleGroupVolumes,
            totalWorkload: workload
        )
    }
}
