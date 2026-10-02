//
//  PreviewWorkoutLoaders.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import Foundation

/// Preview conformer for a workout's contents, an exercise's clips, and the
/// library checks — a three-exercise workout and clips from the clip loader.
public final class PreviewWorkoutLoaders: DiscoverWorkoutDetailLoader, ExerciseClipsLoader, SavedWorkoutCopyChecker, WorkoutCopySaver, @unchecked Sendable {
    public init() {}

    public func detail(ofWorkout templateId: String) async throws -> DiscoverWorkoutDetail {
        DiscoverWorkoutDetail(
            templateId: templateId,
            title: "Lower Body Strength",
            description: "Heavy compounds, then single-leg work.",
            createdBy: "u1",
            exercises: [
                DiscoverWorkoutExercise(id: "e1", name: "Back Squat", sets: (0..<4).map { _ in
                    DiscoverWorkoutSet(reps: 6, weight: 100, weightUnit: "kg", time: nil, distance: nil, distanceUnit: nil)
                }, notes: "Pause at the bottom"),
                DiscoverWorkoutExercise(id: "e2", name: "Romanian Deadlift", sets: [8, 10, 12].map {
                    DiscoverWorkoutSet(reps: $0, weight: 70, weightUnit: "% of 1RM", time: nil, distance: nil, distanceUnit: nil)
                }, notes: nil),
                DiscoverWorkoutExercise(id: "e3", name: "Plank", sets: (0..<3).map { _ in
                    DiscoverWorkoutSet(reps: nil, weight: nil, weightUnit: nil, time: 60, distance: nil, distanceUnit: nil)
                }, notes: nil)
            ]
        )
    }

    public func clips(ofExercise exerciseId: String, limit: Int) async throws -> [DiscoverClipCard] {
        Array(PreviewDiscoverClipCardLoader.cards.prefix(limit))
    }

    public func hasSavedCopy(ofWorkout templateId: String) async -> Bool { false }

    public func saveCopy(ofWorkout templateId: String) async throws {}
}
