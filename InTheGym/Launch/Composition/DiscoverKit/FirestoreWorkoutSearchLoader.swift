//
//  FirestoreWorkoutSearchLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore

/// Public, visible workout cards whose `titleLower` starts with the query,
/// alphabetically. `titleLower` is written by the card projection
/// (`WorkoutCard.ts`); a card projected before it existed has none and is not
/// found until `rebuildDiscoverCards` runs.
///
/// Keeps the `isPublic` and `status` filters every workout card query carries
/// — the rules reject a query on another user's cards without `isPublic` — so
/// it needs a composite index: `isPublic` ↑, `status` ↑, `titleLower` ↑.
struct FirestoreWorkoutSearchLoader: WorkoutSearchLoader {

    func workouts(matching query: String, limit: Int) async throws -> [DiscoverWorkoutCard] {
        let cards = Firestore.firestore()
            .collection("DiscoverWorkouts")
            .whereField("isPublic", isEqualTo: true)
            .whereField("status", isEqualTo: "visible")
        let search = DiscoverSearchPrefix.matching(query, on: "titleLower", in: cards)
            .order(by: "titleLower")
            .limit(to: limit)
        return try await DiscoverCardQuery.page(search, as: DiscoverWorkoutCard.self)
    }
}
