//
//  ExerciseMuscleGroupsLoader.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// Every muscle group a custom exercise can be tagged with.
///
/// **Not StatsKit's `MuscleGroupsLoader`, though it reads the same
/// collection.** Neither framework may import the other, so each declares what
/// it needs, and the composition root's one `MuscleGroups` reader answers both —
/// one reader per path, two protocols. The method is named rather than a bare
/// `loadAll()` so that one adapter can conform to both without overloading on
/// return type.
public protocol ExerciseMuscleGroupsLoader {
    func loadMuscleGroups() async throws -> [ExerciseMuscleGroup]
}

/// A fixed list for SwiftUI previews of the custom exercise form.
public struct PreviewExerciseMuscleGroupsLoader: ExerciseMuscleGroupsLoader {
    public init() {}

    public func loadMuscleGroups() async throws -> [ExerciseMuscleGroup] {
        [
            ExerciseMuscleGroup(id: "chest", name: "Chest", category: .upperBody),
            ExerciseMuscleGroup(id: "shoulders", name: "Shoulders", category: .upperBody),
            ExerciseMuscleGroup(id: "triceps", name: "Triceps", category: .upperBody),
            ExerciseMuscleGroup(id: "quads", name: "Quadriceps", category: .lowerBody),
            ExerciseMuscleGroup(id: "glutes", name: "Glutes", category: .lowerBody),
            ExerciseMuscleGroup(id: "core", name: "Core / Abs", category: .core)
        ]
    }
}
