//
//  FirestoreExerciseCatalogueLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore

/// Every visible exercise card in `DiscoverExercises`, read once per session by
/// DiscoverKit's `CatalogueExerciseSearchLoader` and searched on the device —
/// which is what lets exercise search match inside a word and forgive a typo.
/// Reasonable only because the catalogue is small and curated.
///
/// One equality filter on `status`, so Firestore's automatic index serves it.
/// Decoded per document (`DiscoverCardQuery.page`), so one bad card is skipped
/// rather than emptying the search.
struct FirestoreExerciseCatalogueLoader: ExerciseCatalogueLoader {

    func allExercises() async throws -> [DiscoverExerciseCard] {
        let query = Firestore.firestore()
            .collection("DiscoverExercises")
            .whereField("status", isEqualTo: "visible")
        return try await DiscoverCardQuery.page(query, as: DiscoverExerciseCard.self)
    }
}
