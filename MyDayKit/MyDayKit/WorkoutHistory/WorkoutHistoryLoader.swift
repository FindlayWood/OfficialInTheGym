//
//  WorkoutHistoryLoader.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation

/// The signed-in user's finished sessions of one workout, for the workout page's history card.
///
/// **The user's own sessions only** — this is the personal half of workout stats. How a public
/// workout tends to go for everyone is a different question, answered on the server and shown on
/// DISCOVER; it must not be worked out here by reading other people's sessions.
///
/// Keyed by `templateId`, which is the id of the template the session was started from. A workout
/// saved from DISCOVER is a copy with its own id, so its history is the user's copy alone.
public protocol WorkoutHistoryLoader: Sendable {
    func sessions(forTemplate templateId: String) async throws -> [CompletedWorkoutSession]
}
