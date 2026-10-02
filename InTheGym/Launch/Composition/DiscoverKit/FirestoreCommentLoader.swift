//
//  FirestoreCommentLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Top-level comments, newest first. `parentId == null` selects top-level —
/// which is why the writer stores an explicit `null` rather than leaving the
/// field out: Firestore cannot query for a missing field.
///
/// Loads `visible` and `removed`, never `hidden`: a removed comment may still
/// have replies to anchor, a hidden one is moderation's and is not shown.
struct FirestoreCommentLoader: CommentLoader {

    func topLevelComments(on subject: DiscoverSubject, limit: Int, after last: DiscoverComment?) async throws -> [DiscoverComment] {
        var query = Firestore.firestore()
            .collection(subject.commentsPath)
            .whereField("parentId", isEqualTo: NSNull())
            .whereField("status", in: ["visible", "removed"])
            .order(by: "createdAt", descending: true)
            .order(by: FieldPath.documentID(), descending: true)
            .limit(to: limit)
        if let last {
            query = query.start(after: [DiscoverCardQuery.cursorValue(last.createdAt), last.commentId])
        }
        return try await DiscoverCardQuery.page(query, as: DiscoverComment.self)
    }
}
