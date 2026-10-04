//
//  FirestoreFollowRequestCountLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Counts the signed-in user's pending requests with a server-side count
/// query, a single read whatever the number, rather than fetching them.
struct FirestoreFollowRequestCountLoader: FollowRequestCountLoader {

    let currentUserId: String

    func pendingRequestCount() async throws -> Int {
        let snapshot = try await Firestore.firestore().collection(FollowPath.collection)
            .whereField("followeeId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: "pending")
            .count
            .getAggregation(source: .server)
        return snapshot.count.intValue
    }
}
