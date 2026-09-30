//
//  FirestoreCommentRemover.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Removes one of the signed-in user's comments by clearing its text and
/// marking it `removed` — the one change the security rules allow an author.
/// The document stays so replies under it keep their parent.
struct FirestoreCommentRemover: CommentRemover {

    func removeComment(_ commentId: String, on subject: DiscoverSubject) async throws {
        try await Firestore.firestore().document(subject.commentPath(commentId)).updateData([
            "status": "removed",
            "text": ""
        ])
    }
}
