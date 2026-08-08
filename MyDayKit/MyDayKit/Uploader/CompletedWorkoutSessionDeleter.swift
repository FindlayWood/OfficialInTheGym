//
//  CompletedWorkoutSessionDeleter.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/08/2026.
//

import Foundation

/// Removes a finished session when the workout it belongs to is taken off the
/// day.
///
/// The two copies are treated differently on purpose: the user's history should
/// stop showing a workout they removed, while analytics keeps the event and
/// marks it deleted. One call, because both sides have to move together.
///
/// Takes only the session id — resolving the signed-in user is the composition
/// root's job, as it is for every other saver and deleter in the app.
public protocol CompletedWorkoutSessionDeleter {
    func delete(sessionId: String) async throws
}

struct PreviewCompletedWorkoutSessionDeleter: CompletedWorkoutSessionDeleter {
    func delete(sessionId: String) async throws {
        print("Deleting completed session: \(sessionId)")
    }
}
