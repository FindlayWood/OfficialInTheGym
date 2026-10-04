//
//  FollowsPageQuery.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// One page of `Follows` where `field == userId` and `status` matches, newest
/// first, ordered and resumed by `createdAt` then document id. Migrated follows
/// share one timestamp, so the date alone cannot be a cursor.
///
/// **The one place that query is built.** The follow lists (active, by followee
/// or follower) and the requests inbox (pending, by followee) differ only in
/// field and status, and both run on the composite indexes in
/// `PROFILE_PLAN.md` step 5. Firestore appends the id ordering itself.
/// `otherField` names the person each row is about.
struct FollowsPageQuery {

    let field: String
    let otherField: String
    let status: String

    func page(for userId: String, after cursor: FollowListCursor?, limit: Int) async throws -> [FollowListEntry] {
        var query = Firestore.firestore().collection(FollowPath.collection)
            .whereField(field, isEqualTo: userId)
            .whereField("status", isEqualTo: status)
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
