//
//  FirestorePrivateAccountLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Reads `isPrivate` off the signed-in user's own `Users/{uid}`. Only a literal
/// `true` is private, as `syncProfile` projects it, so the two never disagree
/// about an account with a missing or malformed flag.
struct FirestorePrivateAccountLoader: PrivateAccountLoader {

    let userId: String

    func isPrivate() async throws -> Bool {
        let snapshot = try await Firestore.firestore().document("Users/\(userId)").getDocument()
        return snapshot.get("isPrivate") as? Bool == true
    }
}
