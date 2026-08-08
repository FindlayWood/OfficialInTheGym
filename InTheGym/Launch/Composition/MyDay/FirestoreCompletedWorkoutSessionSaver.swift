//
//  FirestoreCompletedWorkoutSessionSaver.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MyDayKit

/// Writes a finished session to both of its homes:
///
/// - `WorkoutSessions/{id}` — every session, for analytics.
/// - `Users/{userId}/WorkoutSessions/{id}` — the user's own history.
///
/// **One batch, not two writes.** The copies are identical, so a write that
/// half-succeeded would leave the two collections disagreeing about a session
/// with nothing to say which was right. The batch commits both or neither.
///
/// The user is taken from `session.userId` — the person who performed the
/// session — rather than from `UserDefaults`, so a session can never be filed
/// under the wrong user.
public struct FirestoreCompletedWorkoutSessionSaver: CompletedWorkoutSessionSaver {

    public init() {}

    public func save(_ session: CompletedWorkoutSession) async throws {
        let db = Firestore.firestore()
        let batch = db.batch()

        try batch.setData(from: session, forDocument: db.document("WorkoutSessions/\(session.id)"))
        try batch.setData(
            from: session,
            forDocument: db.document("Users/\(session.userId)/WorkoutSessions/\(session.id)")
        )

        try await batch.commit()
    }
}
