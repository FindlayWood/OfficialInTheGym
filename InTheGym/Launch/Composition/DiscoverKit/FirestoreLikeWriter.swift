//
//  FirestoreLikeWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Likes by writing `{target}/Likes/{userId}`, unlikes by deleting it. The
/// counts are the Cloud Functions' to recount.
struct FirestoreLikeWriter: LikeWriter {

    let userId: String

    func setLiked(_ liked: Bool, for target: DiscoverLikeTarget) async throws {
        let ref = Firestore.firestore().document(target.likePath(userId: userId))
        if liked {
            try await ref.setData(["authorId": userId, "createdAt": FieldValue.serverTimestamp()])
        } else {
            try await ref.delete()
        }
    }
}
