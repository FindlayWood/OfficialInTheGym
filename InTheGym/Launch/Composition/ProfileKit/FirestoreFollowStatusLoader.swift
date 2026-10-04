//
//  FirestoreFollowStatusLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Where the signed-in user stands toward each user: one `get` of
/// `Follows/{me}_{them}` each, in parallel.
///
/// Gets, not a query. The `Follows` read rule allows a get by either person
/// named in the id, including for a document that does not exist ("not
/// following"). A query on document ids would have to satisfy the list rule
/// for every possible result, which it cannot express.
struct FirestoreFollowStatusLoader: FollowStatusLoader {

    let currentUserId: String

    func statuses(toward userIds: [String]) async throws -> [String: FollowStatus] {
        let db = Firestore.firestore()
        return try await withThrowingTaskGroup(of: (String, FollowStatus).self) { group in
            for userId in Set(userIds) {
                group.addTask {
                    let snapshot = try await db.document(FollowPath.document(follower: currentUserId, followee: userId)).getDocument()
                    return (userId, FollowStatus(followDocumentStatus: snapshot.exists ? snapshot.get("status") as? String : nil))
                }
            }
            var statuses: [String: FollowStatus] = [:]
            for try await (userId, status) in group {
                statuses[userId] = status
            }
            return statuses
        }
    }
}
