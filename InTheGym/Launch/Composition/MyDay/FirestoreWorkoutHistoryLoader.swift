//
//  FirestoreWorkoutHistoryLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MyDayKit

/// The user's finished sessions of one workout, from `Users/{uid}/WorkoutSessions` — the history
/// copy `FirestoreCompletedWorkoutSessionSaver` writes on `finishSession`.
///
/// **Not the local day files.** They hold every session as `sessionRecord`, but
/// `MyDayFileManagerLoader` prunes them to the last week, so they cannot answer "how many times
/// have I done this". Firestore's local cache includes pending writes, so a session finished
/// offline still counts the moment it is finished.
///
/// One equality filter on `templateId`, which Firestore indexes on its own, so no composite index.
/// Sorting is the summary's job. The owner-only read rule on `Users/{uid}/WorkoutSessions` already
/// allows the query.
///
/// **History starts 2026-10-25.** Until then both session writes were refused by the rules, so a
/// workout done before that reads as done fewer times than it was. Backfilling it from the
/// `Users/{uid}/MyDay` documents is a script's job, not the app's.
///
/// Decodes per document and skips failures, as `FirestoreWorkoutTemplateFetcher` does.
struct FirestoreWorkoutHistoryLoader: WorkoutHistoryLoader {

    let userId: String

    func sessions(forTemplate templateId: String) async throws -> [CompletedWorkoutSession] {
        let snapshot = try await Firestore.firestore()
            .collection("Users/\(userId)/WorkoutSessions")
            .whereField("templateId", isEqualTo: templateId)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: CompletedWorkoutSession.self)
            } catch {
                print("❌ Skipping workout session \(document.documentID): \(error)")
                return nil
            }
        }
    }
}
