//
//  WeekBucket.swift
//  StatsKit
//
//  Created by Findlay Wood on 15/04/2026.
//

import Foundation

// MARK: - WeekBucket
struct WeekBucket {
    let label: String
    let weekStart: Date
    let totalReps: Int
    let totalTime: Int
    let maxWeight: Double
    let volume: Double
}

// MARK: - buildWeeks
func buildWeeks(from dailyStats: [ExerciseDailyStats]) -> [WeekBucket] {
    let calendar = Calendar.current

    // Group daily stats by the start of their week
    let grouped = Dictionary(grouping: dailyStats) { stat in
        calendar.dateInterval(of: .weekOfYear, for: stat.date)?.start ?? stat.date
    }

    // Build sorted buckets
    return grouped
        .sorted { $0.key < $1.key }
        .map { weekStart, stats in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"

            return WeekBucket(
                label: formatter.string(from: weekStart),
                weekStart: weekStart,
                totalReps: stats.reduce(0) { $0 + $1.totalReps },
                totalTime: stats.reduce(0) { $0 + $1.totalTime },
                maxWeight: stats.compactMap(\.maxWeight).max() ?? 0,
                volume: stats.reduce(0) { $0 + $1.totalVolume }
            )
        }
}
