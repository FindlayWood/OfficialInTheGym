//
//  FirestoreWorkoutCommunityLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Reads `community` off `DiscoverWorkouts/{templateId}`, written by the `discoverWorkoutCommunity`
/// function. Absent until three people have done the workout, which reads as `nil` rather than an
/// error — the same card, and so the same read rule, as `FirestoreRatingSummaryLoader`.
struct FirestoreWorkoutCommunityLoader: WorkoutCommunityLoader {

    func community(ofWorkout templateId: String) async throws -> DiscoverWorkoutCommunity? {
        let snapshot = try await Firestore.firestore()
            .document(DiscoverSubject.workout(id: templateId).cardPath)
            .getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: CommunityField.self).community
    }
}

/// Only the one field, so a card whose other fields change shape cannot fail this read.
private struct CommunityField: Decodable {
    let community: DiscoverWorkoutCommunity?
}
