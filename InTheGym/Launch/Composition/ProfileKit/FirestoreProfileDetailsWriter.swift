//
//  FirestoreProfileDetailsWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Writes the display name and bio to Firestore `Users/{uid}`, and nothing else.
///
/// **`updateData`, not `setData`.** It touches exactly the two fields, which
/// is what the `Users/{userId}` update rule in `PROFILE_PLAN.md` step 3
/// allows (`affectedKeys().hasOnly(["displayName", "bio"])`). A merge that
/// wrote anything more would be denied, and must be: that rule is all that
/// stops a client from writing its own `verifiedAccount` or `eliteAccount`.
///
/// The legacy RTDB `users/{uid}` and the public `Profiles/{uid}` follow from
/// this write server-side (`onEditAccount`, `syncProfile`).
struct FirestoreProfileDetailsWriter: ProfileDetailsWriter {

    let userId: String

    func save(_ details: ProfileDetails) async throws {
        try await Firestore.firestore().document("Users/\(userId)").updateData([
            "displayName": details.displayName,
            "bio": details.bio
        ])
    }
}
