//
//  PreviewSearchLoaders.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import Foundation

/// Preview conformer for all three searches: a couple of people, and the
/// preview workouts and exercises whose names start with the query.
public final class PreviewSearchLoaders: PeopleSearchLoader, WorkoutSearchLoader, ExerciseSearchLoader, @unchecked Sendable {

    public init() {}

    public func people(matching query: String, limit: Int) async throws -> [DiscoverUserProfile] {
        Array(PreviewUserProfileLoader.profiles.values.sorted { $0.userId < $1.userId }.prefix(limit))
    }

    public func workouts(matching query: String, limit: Int) async throws -> [DiscoverWorkoutCard] {
        Array(PreviewDiscoverWorkoutCardLoader.cards.filter { $0.title.lowercased().hasPrefix(query) }.prefix(limit))
    }

    public func exercises(matching query: String, limit: Int) async throws -> [DiscoverExerciseCard] {
        Array(PreviewDiscoverExerciseCardLoader.cards.filter { $0.name.lowercased().hasPrefix(query) }.prefix(limit))
    }
}
