//
//  FirestoreDiscoverWorkoutCardLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation


/// Public, visible workout cards from `DiscoverWorkouts`, newest first.
///
/// Filters on `isPublic == true` as well as `status`: the security rules only
/// let a user read another user's card when it is public, so a query without
/// the filter is rejected outright rather than trimmed.
struct FirestoreDiscoverWorkoutCardLoader: DiscoverWorkoutCardLoader {

    func load(limit: Int, after last: DiscoverWorkoutCard?) async throws -> [DiscoverWorkoutCard] {
        var query = Firestore.firestore()
            .collection("DiscoverWorkouts")
            .whereField("isPublic", isEqualTo: true)
            .whereField("status", isEqualTo: "visible")
            .order(by: "createdAt", descending: true)
            .order(by: FieldPath.documentID(), descending: true)
            .limit(to: limit)
        if let last {
            query = query.start(after: [DiscoverCardQuery.cursorValue(last.createdAt), last.templateId])
        }
        return try await DiscoverCardQuery.page(query, as: DiscoverWorkoutCard.self)
    }
}
