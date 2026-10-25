//
//  ExerciseBodySimilarity.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// The second similar-exercise check, made on Save: an exercise that works
/// the same way under a different name. The name check while typing cannot
/// catch "Single-Arm Landmine Press" against "Landmine Press" written another
/// way, or a user's name for a catalogue movement — the body can.
///
/// **Similar means a shared movement pattern and at least one shared muscle
/// group.** Either alone is far too broad: every isolation exercise shares a
/// pattern, and half the catalogue works the shoulders. Ranked by how many
/// muscle groups are shared, then by name, so the closest comes first.
///
/// An exercise with no body fields — an older catalogue entry nobody has
/// tagged — cannot be compared and is left out rather than guessed at.
/// **This only ever asks, never blocks**: two exercises can work the same
/// muscles in the same pattern and still be different exercises.
enum ExerciseBodySimilarity {

    static func matches(
        muscleGroups: Set<String>,
        movementPatterns: Set<String>,
        excludingName name: String,
        in exercises: [Exercise],
        limit: Int
    ) -> [Exercise] {
        let scored: [(exercise: Exercise, shared: Int)] = exercises.compactMap { exercise in
            guard exercise.name.caseInsensitiveCompare(name) != .orderedSame,
                  let groups = exercise.muscleGroups,
                  let patterns = exercise.movementPatterns,
                  !movementPatterns.isDisjoint(with: patterns)
            else { return nil }
            let shared = muscleGroups.intersection(groups).count
            return shared > 0 ? (exercise, shared) : nil
        }
        return scored
            .sorted { lhs, rhs in
                if lhs.shared != rhs.shared { return lhs.shared > rhs.shared }
                return lhs.exercise.name.localizedCaseInsensitiveCompare(rhs.exercise.name) == .orderedAscending
            }
            .prefix(limit)
            .map(\.exercise)
    }
}
