//
//  FirestoreTaggedWorkoutsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// A tag's workouts, most-voted first. Only public templates are ever indexed,
/// so there is nothing private here to filter out.
struct FirestoreTaggedWorkoutsLoader: TaggedWorkoutsLoader {

    func workouts(taggedWith tag: String, limit: Int, after last: DiscoverTagged<DiscoverWorkoutCard>?) async throws -> [DiscoverTagged<DiscoverWorkoutCard>] {
        var query = Firestore.firestore()
            .collection(DiscoverTagPath.taggedWorkouts(tag))
            .order(by: "voteCount", descending: true)
            .order(by: FieldPath.documentID(), descending: true)
            .limit(to: limit)
        if let last {
            query = query.start(after: [last.voteCount, last.id])
        }
        return try await DiscoverCardQuery.page(query, as: DiscoverTagged<DiscoverWorkoutCard>.self)
    }
}
