//
//  FirestoreTaggedExercisesLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// A tag's exercises, most-voted first, with a document-id tiebreak so equal
/// vote counts page in a fixed order.
struct FirestoreTaggedExercisesLoader: TaggedExercisesLoader {

    func exercises(taggedWith tag: String, limit: Int, after last: DiscoverTagged<DiscoverExerciseCard>?) async throws -> [DiscoverTagged<DiscoverExerciseCard>] {
        var query = Firestore.firestore()
            .collection(DiscoverTagPath.taggedExercises(tag))
            .order(by: "voteCount", descending: true)
            .order(by: FieldPath.documentID(), descending: true)
            .limit(to: limit)
        if let last {
            query = query.start(after: [last.voteCount, last.id])
        }
        return try await DiscoverCardQuery.page(query, as: DiscoverTagged<DiscoverExerciseCard>.self)
    }
}
