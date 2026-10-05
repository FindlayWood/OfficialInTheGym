//
//  FirestoreExerciseSearchLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore

/// Visible exercise cards whose `nameLower` starts with the query,
/// alphabetically. `nameLower` is written by the card projection
/// (`ExerciseCard.ts`); cards projected before it existed are not found until
/// `rebuildDiscoverCards` runs.
///
/// Filters on `status` as every exercise card query does, so it needs a
/// composite index: `status` ↑, `nameLower` ↑.
struct FirestoreExerciseSearchLoader: ExerciseSearchLoader {

    func exercises(matching query: String, limit: Int) async throws -> [DiscoverExerciseCard] {
        let cards = Firestore.firestore()
            .collection("DiscoverExercises")
            .whereField("status", isEqualTo: "visible")
        let search = DiscoverSearchPrefix.matching(query, on: "nameLower", in: cards)
            .order(by: "nameLower")
            .limit(to: limit)
        return try await DiscoverCardQuery.page(search, as: DiscoverExerciseCard.self)
    }
}
