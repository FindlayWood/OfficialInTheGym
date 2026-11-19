//
//  WorkoutSetOrder.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation

/// The order a workout's sets are meant to be done in, and so which set comes next once one is
/// logged. The session screen flashes that set and scrolls it to the middle.
///
/// **An exercise on its own runs its sets in order. A superset runs in rounds**: set 1 of 1a, set 1
/// of 1b, then back to set 2 of 1a. An exercise with fewer sets than its partners drops out of the
/// later rounds. The groups come from `WorkoutSupersetLayout`, the one definition.
///
/// **Next is the first set after the one just logged that is not logged yet**, so a set logged out
/// of order does not send the user back over work already done. Past the end it wraps to the first
/// set still open, which picks up anything skipped. `nil` once everything is logged.
enum WorkoutSetOrder {

    /// One set, by the ids the screen addresses it with.
    struct Step: Equatable {
        let exerciseId: String
        let setId: String
    }

    /// Every set in the order it is meant to be done.
    static func steps(for exercises: [WorkoutExerciseModel]) -> [Step] {
        let entries = WorkoutSupersetLayout(exercises: exercises).entries
        var steps: [Step] = []
        var group: [WorkoutExerciseModel] = []

        for (exercise, entry) in zip(exercises, entries) {
            group.append(exercise)
            guard !entry.position.continuesToNext else { continue }
            let rounds = group.map(\.sets.count).max() ?? 0
            for round in 0..<rounds {
                for member in group where round < member.sets.count {
                    steps.append(Step(exerciseId: member.id, setId: member.sets[round].id))
                }
            }
            group = []
        }
        return steps
    }

    /// The set to do after `logged`, skipping any already logged.
    static func next(
        after logged: Step,
        in exercises: [WorkoutExerciseModel],
        isLogged: (Step) -> Bool
    ) -> Step? {
        let steps = steps(for: exercises)
        guard let index = steps.firstIndex(of: logged) else { return nil }
        let after = steps[(index + 1)...]
        let before = steps[..<index]
        return (after + before).first { !isLogged($0) }
    }
}
