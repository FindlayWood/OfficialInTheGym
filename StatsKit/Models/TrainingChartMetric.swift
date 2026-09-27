//
//  TrainingChartMetric.swift
//  StatsKit
//
//  Created by Findlay Wood on 13/08/2026.
//

import SwiftUI

// MARK: - TrainingChartMetric
/// What the home chart plots.
///
/// Four series over one set of buckets, chosen by the user. **This is a display
/// choice and nothing more** — unlike `TrainingLoadMetric`, whose two cases feed
/// a calculation and are kept apart because merging them would hide which work
/// was missed. Here the same weeks are simply re-read through a different field,
/// so adding a case costs nothing and none of them interact.
///
/// **The cases carry no colour.** Each used to own one — volume blue, sets
/// orange and so on — so the whole chart changed hue under the toggle. The chart
/// is drawn in `Color.darkColor` with opacity carrying magnitude, matching
/// `ActivityGrid`, which is what makes the two cards read as one system; a
/// per-metric palette on top of that would be a second colour dimension saying
/// nothing the selected pill does not already say.
public enum TrainingChartMetric: String, CaseIterable, Identifiable, Sendable {
    case volume
    case sets
    case reps
    case time

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .volume: return "Volume"
        case .sets:   return "Sets"
        case .reps:   return "Reps"
        case .time:   return "Time"
        }
    }

    public func value(from week: TrainingWeek) -> Double {
        switch self {
        case .volume: return week.volume
        case .sets:   return Double(week.sets)
        case .reps:   return Double(week.reps)
        case .time:   return Double(week.time)
        }
    }

    /// The headline rendering — big, so it is abbreviated.
    public func formatted(_ value: Double) -> String {
        switch self {
        case .volume:
            return value >= 1000
                ? String(format: "%.1fk", value / 1000)
                : String(format: "%.0f", value)
        case .sets, .reps:
            return String(format: "%.0f", value)
        case .time:
            // Stored as a plain second count, as everywhere else in the app —
            // see the note on `WorkoutSetModel.time`.
            let seconds = Int(value)
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
        }
    }

    /// What follows the headline number, so the figure is readable on its own.
    /// Time formats its own units, so it has none.
    public var unitLabel: String? {
        switch self {
        case .volume: return "volume"
        case .sets:   return "sets"
        case .reps:   return "reps"
        case .time:   return nil
        }
    }
}
