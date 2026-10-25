//
//  ExerciseMovementPatternsLoader.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// Every movement pattern a custom exercise can be tagged with.
///
/// The counterpart of StatsKit's `MovementTypesLoader`, answered by the same
/// `MovementTypes` reader in the composition root — see
/// `ExerciseMuscleGroupsLoader` for why there are two protocols and one reader.
public protocol ExerciseMovementPatternsLoader {
    func loadMovementPatterns() async throws -> [ExerciseMovementPattern]
}

/// A fixed list for SwiftUI previews of the custom exercise form.
public struct PreviewExerciseMovementPatternsLoader: ExerciseMovementPatternsLoader {
    public init() {}

    public func loadMovementPatterns() async throws -> [ExerciseMovementPattern] {
        [
            ExerciseMovementPattern(id: "squat", name: "Squat"),
            ExerciseMovementPattern(id: "hinge", name: "Hinge"),
            ExerciseMovementPattern(id: "push_horizontal", name: "Push Horizontal"),
            ExerciseMovementPattern(id: "pull_vertical", name: "Pull Vertical"),
            ExerciseMovementPattern(id: "isolation", name: "Isolation")
        ]
    }
}
