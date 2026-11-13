//
//  WorkoutServicesSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 12/11/2026.
//

import Foundation
@testable import ProfileKit

/// Public workouts and the library in one message log. Results are settable. Never asserts — the
/// test does.
final class WorkoutServicesSpy: ProfileWorkoutsLoader, ProfileLibraryLoader, @unchecked Sendable {

    enum Message: Equatable {
        case publicWorkouts(String, limit: Int)
        case allWorkouts
    }

    private(set) var receivedMessages: [Message] = []
    /// Delivered in order, the last one repeating, so a test can make a refresh fail.
    var publicResults: [Result<[ProfileWorkout], Error>] = [.success([])]
    var libraryResults: [Result<[ProfileWorkout], Error>] = [.success([])]

    func publicWorkouts(of userId: String, limit: Int) async throws -> [ProfileWorkout] {
        receivedMessages.append(.publicWorkouts(userId, limit: limit))
        return try next(&publicResults).get()
    }

    func allWorkouts() async throws -> [ProfileWorkout] {
        receivedMessages.append(.allWorkouts)
        return try next(&libraryResults).get()
    }

    private func next(_ results: inout [Result<[ProfileWorkout], Error>]) -> Result<[ProfileWorkout], Error> {
        results.count > 1 ? results.removeFirst() : results[0]
    }
}
