//
//  SearchLoaderSpy.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 05/10/2026.
//

import Foundation
@testable import DiscoverKit

/// All three searches in one message log, each answered per query from its own
/// table, or failed by its own error so a test can fail one kind alone. Never
/// asserts — the test does.
final class SearchLoaderSpy: PeopleSearchLoader, WorkoutSearchLoader, ExerciseSearchLoader, @unchecked Sendable {

    enum Message: Hashable {
        case people(String, limit: Int)
        case workouts(String, limit: Int)
        case exercises(String, limit: Int)
    }

    private(set) var receivedMessages: [Message] = []
    var people: [String: [DiscoverUserProfile]] = [:]
    var workouts: [String: [DiscoverWorkoutCard]] = [:]
    var exercises: [String: [DiscoverExerciseCard]] = [:]
    var peopleError: Error?
    var workoutsError: Error?
    var exercisesError: Error?

    func people(matching query: String, limit: Int) async throws -> [DiscoverUserProfile] {
        receivedMessages.append(.people(query, limit: limit))
        if let peopleError { throw peopleError }
        return people[query] ?? []
    }

    func workouts(matching query: String, limit: Int) async throws -> [DiscoverWorkoutCard] {
        receivedMessages.append(.workouts(query, limit: limit))
        if let workoutsError { throw workoutsError }
        return workouts[query] ?? []
    }

    func exercises(matching query: String, limit: Int) async throws -> [DiscoverExerciseCard] {
        receivedMessages.append(.exercises(query, limit: limit))
        if let exercisesError { throw exercisesError }
        return exercises[query] ?? []
    }
}
