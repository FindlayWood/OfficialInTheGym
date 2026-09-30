//
//  FirestoreTagVoteWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Writes the signed-in user's whole tag set on a subject, replacing the last.
/// An empty set deletes the document — a user with no tags on something is
/// not a voter on it at all.
struct FirestoreTagVoteWriter: TagVoteWriter {

    let userId: String

    func setMyTags(_ tags: [String], on subject: DiscoverSubject) async throws {
        let ref = Firestore.firestore().document(subject.tagVotePath(userId: userId))
        if tags.isEmpty {
            try await ref.delete()
        } else {
            try await ref.setData([
                "tags": tags,
                "authorId": userId,
                "updatedAt": FieldValue.serverTimestamp()
            ])
        }
    }
}
