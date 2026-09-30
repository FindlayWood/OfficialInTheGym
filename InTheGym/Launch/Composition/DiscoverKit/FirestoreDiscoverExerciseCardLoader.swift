//
//  FirestoreDiscoverExerciseCardLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation


/// Visible exercise cards from `DiscoverExercises`, alphabetically. Exercises
/// are a catalogue with no visibility of their own, so only `status` filters.
struct FirestoreDiscoverExerciseCardLoader: DiscoverExerciseCardLoader {

    func load(limit: Int, after last: DiscoverExerciseCard?) async throws -> [DiscoverExerciseCard] {
        var query = Firestore.firestore()
            .collection("DiscoverExercises")
            .whereField("status", isEqualTo: "visible")
            .order(by: "name")
            .order(by: FieldPath.documentID())
            .limit(to: limit)
        if let last {
            query = query.start(after: [last.name, last.exerciseId])
        }
        return try await DiscoverCardQuery.page(query, as: DiscoverExerciseCard.self)
    }
}
