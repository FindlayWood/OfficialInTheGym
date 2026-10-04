//
//  FirestoreFollowListLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// One page of a follow list: `Follows` where the user is the followee
/// (followers) or the follower (following), active only, newest first.
///
/// Ordered by `createdAt` then document id, and resumed after both. Migrated
/// follows share one timestamp. Needs the composite indexes
/// `(followeeId, status, createdAt desc)` and `(followerId, status, createdAt
/// desc)` in `PROFILE_PLAN.md` step 5. Firestore appends the id ordering itself.
///
/// The `status == active` filter is also what lets the query past the rules,
/// which allow anyone to list active follows and nothing else.
struct FirestoreFollowListLoader: FollowListLoader {

    func page(_ kind: FollowListKind, of userId: String, after cursor: FollowListCursor?, limit: Int) async throws -> [FollowListEntry] {
        let ownField = kind == .followers ? "followeeId" : "followerId"
        let otherField = kind == .followers ? "followerId" : "followeeId"

        var query = Firestore.firestore().collection(FollowPath.collection)
            .whereField(ownField, isEqualTo: userId)
            .whereField("status", isEqualTo: "active")
            .order(by: "createdAt", descending: true)
            .order(by: FieldPath.documentID(), descending: true)
        if let cursor {
            query = query.start(after: [Timestamp(date: cursor.createdAt), cursor.followId])
        }

        let snapshot = try await query.limit(to: limit).getDocuments()
        return snapshot.documents.compactMap { document in
            guard let other = document.get(otherField) as? String else { return nil }
            // A just-created follow can read back before the server timestamp
            // resolves; it sorts as newest, which is what it is.
            let createdAt = (document.get("createdAt") as? Timestamp)?.dateValue() ?? .now
            return FollowListEntry(followId: document.documentID, userId: other, createdAt: createdAt)
        }
    }
}
