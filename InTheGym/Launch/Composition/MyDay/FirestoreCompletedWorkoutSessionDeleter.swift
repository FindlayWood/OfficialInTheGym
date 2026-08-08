//
//  FirestoreCompletedWorkoutSessionDeleter.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MyDayKit

/// Removes a finished session when its workout is taken off the day.
///
/// The two copies are treated differently on purpose:
/// - the user's copy is **deleted** — their history should not show a workout
///   they removed;
/// - the analytics copy is **kept and marked** with `deletedAt` — a deletion
///   that was never recorded cannot be reconstructed afterwards.
///
/// Both in one batch, so the two can never disagree about whether the session
/// was removed.
///
/// `updateData` on a missing document fails the whole batch, and that is the
/// wanted behaviour rather than a hazard: the two copies are only ever written
/// together, so either both exist or neither does. A workout completed before
/// this shipped has neither — removing it fails the batch and changes nothing,
/// which is exactly right. Do not soften this to `setData(merge:)`; that would
/// create a stub document holding nothing but a `deletedAt`.
public struct FirestoreCompletedWorkoutSessionDeleter: CompletedWorkoutSessionDeleter {

    public init() {}

    public func delete(sessionId: String) async throws {
        let db = Firestore.firestore()
        let userID = UserDefaults.currentUser.uid
        let batch = db.batch()

        batch.deleteDocument(db.document("Users/\(userID)/WorkoutSessions/\(sessionId)"))
        batch.updateData(
            ["deletedAt": Timestamp(date: Date())],
            forDocument: db.document("WorkoutSessions/\(sessionId)")
        )

        try await batch.commit()
    }
}
