//
//  WeightUnit+Kilograms.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/08/2026.
//

import Foundation

extension WeightUnit {

    /// The load in kilograms for a raw stats log.
    ///
    /// Stats compare loads across sessions, so everything is stored in one unit.
    /// Units that describe a *prescription* rather than an absolute load
    /// (`% of 1RM`, `% of BW`, `Max`) and bodyweight (`BW`, which carries no
    /// number at all) have no kilogram value and normalise to zero, as does an
    /// absent unit.
    ///
    /// This is the single definition shared by an exercise logged on its own
    /// (`ExerciseCompletions.getStats()`) and a set logged inside a workout
    /// session (`WorkoutSetRecord.getStats(...)`) — the two write to the same
    /// collection and must normalise identically.
    static func kilograms(_ weight: Double?, unit: WeightUnit?) -> Double {
        guard let weight, let unit else { return 0 }
        switch unit {
        case .kg:
            return weight
        case .lbs:
            return weight * 0.453592
        case .percent1RM, .percentBW, .max, .bw:
            return 0
        }
    }
}
