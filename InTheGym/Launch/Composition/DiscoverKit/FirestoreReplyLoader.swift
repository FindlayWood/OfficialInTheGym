//
//  FirestoreReplyLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// The replies to one comment, oldest first. `visible` and `removed` for the
/// reason `FirestoreCommentLoader` gives; the screen drops removed replies,
/// which have nothing under them.
struct FirestoreReplyLoader: ReplyLoader {

    func replies(to commentId: String, on subject: DiscoverSubject) async throws -> [DiscoverComment] {
        let query = Firestore.firestore()
            .collection(subject.commentsPath)
            .whereField("parentId", isEqualTo: commentId)
            .whereField("status", in: ["visible", "removed"])
            .order(by: "createdAt")
            .order(by: FieldPath.documentID())
        return try await DiscoverCardQuery.page(query, as: DiscoverComment.self)
    }
}
