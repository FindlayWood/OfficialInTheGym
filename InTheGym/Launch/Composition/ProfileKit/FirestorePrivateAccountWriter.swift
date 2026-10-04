//
//  FirestorePrivateAccountWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Writes `isPrivate` on `Users/{uid}`, and nothing else. The `Users` update
/// rule's `hasOnly` list gains `isPrivate` in step 6. From here the server does
/// the rest: `syncProfile` copies it to `Profiles` (which the `Follows` create
/// rule reads), and `approvePendingFollows` approves waiting requests when it
/// goes false.
struct FirestorePrivateAccountWriter: PrivateAccountWriter {

    let userId: String

    func setPrivate(_ isPrivate: Bool) async throws {
        try await Firestore.firestore().document("Users/\(userId)").updateData(["isPrivate": isPrivate])
    }
}
