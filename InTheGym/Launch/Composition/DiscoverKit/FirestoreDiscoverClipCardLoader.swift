//
//  FirestoreDiscoverClipCardLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation


/// Public, visible clip cards from `DiscoverClips`, newest first. Filters on
/// `isPublic` for the reason given on `FirestoreDiscoverWorkoutCardLoader`.
struct FirestoreDiscoverClipCardLoader: DiscoverClipCardLoader {

    func load(limit: Int, after last: DiscoverClipCard?) async throws -> [DiscoverClipCard] {
        var query = Firestore.firestore()
            .collection("DiscoverClips")
            .whereField("isPublic", isEqualTo: true)
            .whereField("status", isEqualTo: "visible")
            .order(by: "uploadedAt", descending: true)
            .order(by: FieldPath.documentID(), descending: true)
            .limit(to: limit)
        if let last {
            query = query.start(after: [DiscoverCardQuery.cursorValue(last.uploadedAt), last.clipId])
        }
        return try await DiscoverCardQuery.page(query, as: DiscoverClipCard.self)
    }
}
