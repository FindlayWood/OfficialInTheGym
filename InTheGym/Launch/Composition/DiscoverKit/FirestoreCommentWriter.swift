//
//  FirestoreCommentWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Posts a comment as the signed-in user.
///
/// - `parentId` is always written, as `null` for a top-level comment — the
///   loader selects top-level comments by querying for `null`.
/// - `status` is written `visible`; the security rules accept nothing else on
///   create, and only moderation or the author's removal changes it after.
/// - `commentId` duplicates the document id so the comment decodes without a
///   Firestore-specific property wrapper in the framework.
/// - No counts: `likeCount` / `replyCount` are the Cloud Functions' to write.
struct FirestoreCommentWriter: CommentWriter {

    let userId: String

    func postComment(_ text: String, replyingTo parentId: String?, on subject: DiscoverSubject) async throws -> DiscoverComment {
        let ref = Firestore.firestore().collection(subject.commentsPath).document()
        try await ref.setData([
            "commentId": ref.documentID,
            "authorId": userId,
            "text": text,
            "parentId": parentId ?? NSNull(),
            "status": "visible",
            "createdAt": FieldValue.serverTimestamp()
        ])
        return DiscoverComment(
            commentId: ref.documentID,
            authorId: userId,
            text: text,
            parentId: parentId,
            createdAt: Date()
        )
    }
}
