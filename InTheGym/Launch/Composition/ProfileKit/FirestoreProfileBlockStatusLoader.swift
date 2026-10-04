//
//  FirestoreProfileBlockStatusLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Whether `Users/{me}/BlockedUsers/{them}` exists. It is the signed-in user's
/// own block list, the one the rules let them read, at the path
/// `DiscoverBlockPath` defines.
struct FirestoreProfileBlockStatusLoader: ProfileBlockStatusLoader {

    let userId: String

    func hasBlocked(_ blockedId: String) async throws -> Bool {
        try await Firestore.firestore()
            .collection(DiscoverBlockPath.blockedUsers(of: userId))
            .document(blockedId)
            .getDocument()
            .exists
    }
}
