//
//  FirestoreBlockedUsersWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Blocks by writing `Users/{uid}/BlockedUsers/{blockedUid}`, unblocks by
/// deleting it.
struct FirestoreBlockedUsersWriter: BlockedUsersWriter {

    let userId: String

    func setBlocked(_ blocked: Bool, userId blockedId: String) async throws {
        let ref = Firestore.firestore()
            .collection(DiscoverBlockPath.blockedUsers(of: userId))
            .document(blockedId)
        if blocked {
            try await ref.setData(["createdAt": FieldValue.serverTimestamp()])
        } else {
            try await ref.delete()
        }
    }
}
