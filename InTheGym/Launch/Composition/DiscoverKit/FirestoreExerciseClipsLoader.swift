//
//  FirestoreExerciseClipsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// One exercise's newest public, visible clips — `DiscoverClips` filtered on
/// `exerciseId`, which the clip card projection carries.
struct FirestoreExerciseClipsLoader: ExerciseClipsLoader {

    func clips(ofExercise exerciseId: String, limit: Int) async throws -> [DiscoverClipCard] {
        let query = Firestore.firestore()
            .collection("DiscoverClips")
            .whereField("exerciseId", isEqualTo: exerciseId)
            .whereField("isPublic", isEqualTo: true)
            .whereField("status", isEqualTo: "visible")
            .order(by: "uploadedAt", descending: true)
            .limit(to: limit)
        return try await DiscoverCardQuery.page(query, as: DiscoverClipCard.self)
    }
}
