//
//  PreviewSearchLoaders.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import Foundation

/// Preview conformer for all three searches: a couple of people, and the
/// preview workouts and exercises matched by the same rules the real search
/// uses — word starts for workouts, `DiscoverExerciseMatcher` for exercises.
public final class PreviewSearchLoaders: PeopleSearchLoader, WorkoutSearchLoader, ExerciseSearchLoader, @unchecked Sendable {

    public init() {}

    public func people(matching query: String, limit: Int) async throws -> [DiscoverUserProfile] {
        Array(PreviewUserProfileLoader.profiles.values.sorted { $0.userId < $1.userId }.prefix(limit))
    }

    public func workouts(matching query: String, limit: Int) async throws -> [DiscoverWorkoutCard] {
        let words = DiscoverSearchQuery.words(query)
        return Array(PreviewDiscoverWorkoutCardLoader.cards.filter { DiscoverSearchQuery.matches(words, in: [$0.title]) }.prefix(limit))
    }

    public func exercises(matching query: String, limit: Int) async throws -> [DiscoverExerciseCard] {
        DiscoverExerciseMatcher.search(query, in: PreviewDiscoverExerciseCardLoader.cards, limit: limit)
    }
}
