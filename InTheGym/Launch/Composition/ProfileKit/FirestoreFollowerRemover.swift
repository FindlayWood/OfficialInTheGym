//
//  FirestoreFollowerRemover.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Deletes `Follows/{them}_{me}`, removing a follower. The `Follows` delete
/// rule allows either person in the relationship to end it.
struct FirestoreFollowerRemover: FollowerRemover {

    let currentUserId: String

    func removeFollower(_ userId: String) async throws {
        try await Firestore.firestore().document(FollowPath.document(follower: userId, followee: currentUserId)).delete()
    }
}
