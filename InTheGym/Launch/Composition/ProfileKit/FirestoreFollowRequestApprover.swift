//
//  FirestoreFollowRequestApprover.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Approves a request: `Follows/{them}_{me}` from `pending` to `active`, with
/// `approvedAt`. `updateData` of exactly those two keys, which is all the
/// `Follows` update rule lets the followee change (`PROFILE_PLAN.md` step 6).
/// The counts follow server-side.
struct FirestoreFollowRequestApprover: FollowRequestApprover {

    let currentUserId: String

    func approve(_ userId: String) async throws {
        try await Firestore.firestore().document(FollowPath.document(follower: userId, followee: currentUserId)).updateData([
            "status": "active",
            "approvedAt": FieldValue.serverTimestamp()
        ])
    }
}
