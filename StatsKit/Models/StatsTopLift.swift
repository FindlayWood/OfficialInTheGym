//
//  StatsTopLift.swift
//  StatsKit
//
//  Created by Findlay Wood on 27/10/2026.
//

import Foundation

// MARK: - StatsTopLift
/// One lift's trend for the free STATS view: the heaviest set in the last four weeks against the
/// heaviest in the four before — "your squat is up 5kg".
///
/// **Best weight, not volume.** Volume needs explaining; a heavier best set does not. The figure
/// is `ExerciseDailyStats.maxWeight`, which the server keeps in kilograms (raw logs are normalised
/// through `WeightUnit.kilograms` before they are written), so the card always reads kg.
///
/// **A lift with no weighted set in the recent window is not a lift** and builds `nil` —
/// bodyweight, timed and `% of 1RM` work all store a `maxWeight` of 0, and "0 kg" would be a
/// reading of nothing. With no earlier weighted set, `previousBest` is `nil` and there is no change
/// to report: a first appearance is not a gain from zero.
struct StatsTopLift: Equatable {

    let exerciseID: String
    let name: String

    /// Heaviest set in the last 28 days, kg.
    let recentBest: Double

    /// Heaviest set in the 28 days before that, kg. `nil` if there was none.
    let previousBest: Double?

    /// Recent minus previous, kg. `nil` when there is nothing to compare with.
    var change: Double? {
        previousBest.map { recentBest - $0 }
    }

    /// The start of the earliest day the comparison needs — what to fetch from.
    static func fetchStart(asOf: Date) -> Date {
        StatsDay.startOfDay(daysAgo: StatsFreeSummary.topLiftWindowDays * 2 - 1, from: asOf)
    }

    init?(exerciseID: String, stats: [ExerciseDailyStats], asOf: Date = .now) {
        let window = StatsFreeSummary.topLiftWindowDays
        let recentKeys = Set((0..<window).map { StatsDay.key(daysAgo: $0, from: asOf) })
        let previousKeys = Set((window..<(window * 2)).map { StatsDay.key(daysAgo: $0, from: asOf) })

        let recent = stats.filter { recentKeys.contains($0.id) }
        guard let recentBest = Self.best(in: recent) else { return nil }

        // The newest name wins: a custom exercise can be renamed, and the card should read as
        // the user calls it now.
        guard let name = recent
            .sorted(by: { $0.id > $1.id })
            .lazy
            .compactMap(\.exerciseName)
            .first(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty })
        else { return nil }

        self.exerciseID = exerciseID
        self.name = name
        self.recentBest = recentBest
        self.previousBest = Self.best(in: stats.filter { previousKeys.contains($0.id) })
    }

    private static func best(in stats: [ExerciseDailyStats]) -> Double? {
        stats.compactMap(\.maxWeight).filter { $0 > 0 }.max()
    }
}
