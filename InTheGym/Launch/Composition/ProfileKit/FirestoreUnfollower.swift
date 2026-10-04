//
//  FirestoreUnfollower.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Deletes the signed-in user's `Follows/{me}_{them}`, which unfollows, or
/// withdraws a request. Deleting a document that is already gone succeeds,
/// so a double tap is harmless.
struct FirestoreUnfollower: Unfollower {

    let currentUserId: String

    func unfollow(_ userId: String) async throws {
        try await Firestore.firestore().document(FollowPath.document(follower: currentUserId, followee: userId)).delete()
    }
}
