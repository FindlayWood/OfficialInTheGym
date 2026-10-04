//
//  FirestoreFollowWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Follows someone: creates `Follows/{me}_{them}` with `status` decided the way
/// the create rule demands it, `"pending"` if their `Profiles.isPrivate` is
/// true and `"active"` otherwise (`PROFILE_PLAN.md` step 5).
///
/// **In a transaction, and create-only.** If the document already exists, the
/// user already follows or has asked, so its status is returned and nothing is
/// written. A blind `setData` would be an update, which only the followee may
/// make, and it could try to turn a pending request into an approved one.
struct FirestoreFollowWriter: FollowWriter {

    let currentUserId: String

    func follow(_ userId: String) async throws -> FollowStatus {
        let db = Firestore.firestore()
        let followRef = db.document(FollowPath.document(follower: currentUserId, followee: userId))
        let profileRef = db.document("Profiles/\(userId)")
        let follower = currentUserId

        let status = try await db.runTransaction { transaction, errorPointer -> Any? in
            do {
                let existing = try transaction.getDocument(followRef)
                if existing.exists {
                    return existing.get("status") as? String
                }
                let profile = try transaction.getDocument(profileRef)
                let status = profile.get("isPrivate") as? Bool == true ? "pending" : "active"
                transaction.setData([
                    "followerId": follower,
                    "followeeId": userId,
                    "status": status,
                    "createdAt": FieldValue.serverTimestamp()
                ], forDocument: followRef)
                return status
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
        return FollowStatus(followDocumentStatus: status as? String)
    }
}
