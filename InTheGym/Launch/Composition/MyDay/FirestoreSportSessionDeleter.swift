//
//  FirestoreSportSessionDeleter.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import MyDayKit

/// Deletes `Users/{userId}/SportSessions/{id}` when the session is taken off the day. This path
/// only — the counterpart to `FirestoreSportSessionSaver`.
///
/// A hard delete, with no analytics copy kept and marked as `WorkoutSessions` does: there is no
/// top-level sport collection, and the DailyTotals trigger on delete is what takes the session's
/// load back out of the day.
final class FirestoreSportSessionDeleter: SportSessionDeleter {

    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    func delete(sessionId: String) async throws {
        try await Firestore.firestore()
            .collection("Users/\(userId)/SportSessions")
            .document(sessionId)
            .delete()
    }
}
