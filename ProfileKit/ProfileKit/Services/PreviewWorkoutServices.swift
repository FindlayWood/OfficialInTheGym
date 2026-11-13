//
//  PreviewWorkoutServices.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import Foundation

/// Preview conformer for workouts: four public workouts, one rated, and a library that adds two
/// private ones.
public final class PreviewWorkoutServices: ProfileWorkoutsLoader, ProfileLibraryLoader, @unchecked Sendable {

    public init() {}

    public func publicWorkouts(of userId: String, limit: Int) async throws -> [ProfileWorkout] {
        Array(Self.publicSample(createdBy: userId).prefix(limit))
    }

    public func allWorkouts() async throws -> [ProfileWorkout] {
        Self.publicSample(createdBy: "me") + [
            ProfileWorkout(workoutId: "p1", title: "Knee rehab", createdBy: "me", exerciseCount: 4, createdAt: .now, isPublic: false),
            ProfileWorkout(workoutId: "p2", title: "Saturday Upper", createdBy: "me", exerciseCount: 6, createdAt: .now, isPublic: false)
        ]
    }

    private static func publicSample(createdBy: String) -> [ProfileWorkout] {
        [
            ProfileWorkout(
                workoutId: "w1", title: "Saturday Upper", createdBy: createdBy, exerciseCount: 6, createdAt: .now,
                isPublic: true, ratingCount: 3, ratingSum: 24, averageRating: 8, commentCount: 2, tags: ["upper", "strength"]
            ),
            ProfileWorkout(workoutId: "w2", title: "Leg day", createdBy: createdBy, exerciseCount: 5, createdAt: .now, isPublic: true, tags: ["legs"]),
            ProfileWorkout(workoutId: "w3", title: "Morning mobility", createdBy: createdBy, exerciseCount: 8, createdAt: .now, isPublic: true),
            ProfileWorkout(workoutId: "w4", title: "Conditioning", createdBy: createdBy, exerciseCount: 4, createdAt: .now, isPublic: true)
        ]
    }
}
