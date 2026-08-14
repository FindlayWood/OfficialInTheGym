//
//  TrainingLoadMetric.swift
//  StatsKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

// MARK: - TrainingLoadMetric
/// What "load" is measured in.
///
/// The two are kept **separate on purpose, and must not be merged into a single
/// number.** They are measured over different work and neither is complete:
///
/// - `.session` only exists for work done inside a workout, because RPE is
///   asked for at the end of a session. An exercise logged on its own produces
///   a `DailyTotal` with no `totalWorkload` at all.
/// - `.volume` under-weights unloaded work rather than ignoring it. The client
///   stores no kilogram value for bodyweight, `% of 1RM`, `% of BW` or `Max`
///   (`WeightUnit.kilograms` returns 0 — they are prescriptions or bodyweight,
///   not loads), but the DailyTotals function works the day's volume out as
///   `(1 + weightKg) × reps`, so **a bodyweight set still contributes its rep
///   count.** A calisthenics session registers; it registers far below a loaded
///   session of the same reps, which is a difference of scale, not an absence.
///   The `+ 1` lives in that Cloud Function, outside this repository — do not
///   re-derive volume on the client to "fix" a number that looks small.
///
/// Averaging them, or falling back from one to the other, would hide which kind
/// of work is missing behind a number that looks complete. Two ratios that each
/// say what they cover is the honest presentation.
public enum TrainingLoadMetric: String, CaseIterable, Identifiable, Sendable {

    /// Duration × RPE, summed over the day's completed workouts.
    case session

    /// Reps × weight, summed over every set.
    case volume

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .session: return "Session load"
        case .volume:  return "Volume"
        }
    }

    /// What the metric is built from — shown under the ratio, because "1.24" is
    /// meaningless without knowing which work it counted.
    public var subtitle: String {
        switch self {
        case .session: return "Duration × RPE"
        case .volume:  return "Reps × weight"
        }
    }

    public var explanation: String {
        switch self {
        case .session:
            return "Counts every workout you finished, whatever kind of training it was — bodyweight, cardio and timed work all register, because it measures effort rather than weight moved. Exercises logged outside a workout aren't included."
        case .volume:
            return "Counts the weight you moved across every set. Bodyweight and time-based sets don't contribute, so this reads low if most of your training isn't loaded."
        }
    }

    /// What this day contributed.
    ///
    /// A day with no workout contributes **zero** session load rather than being
    /// skipped — it is a day on which no session load was accumulated, and the
    /// chronic average has to see it as such or a week off would not register.
    public func load(from total: DailyTotal) -> Double {
        switch self {
        case .session: return total.totalWorkload ?? 0
        case .volume:  return total.totalVolume
        }
    }
}

// MARK: - Load series
public extension Array where Element == DailyTotal {

    /// The day-keyed load series `ACWR.rolling` consumes.
    ///
    /// Uses `uniquingKeysWith` rather than `Dictionary(uniqueKeysWithValues:)`,
    /// which traps on a duplicate key. Ids are Firestore document ids and so are
    /// unique today, but a crash is a bad way to find out that stopped being
    /// true.
    func loadByDay(_ metric: TrainingLoadMetric) -> [String: Double] {
        Dictionary(map { ($0.id, metric.load(from: $0)) }, uniquingKeysWith: +)
    }
}
