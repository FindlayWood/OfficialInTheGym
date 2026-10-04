//
//  FirestoreHighlightCandidatesLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// The signed-in user's `ExerciseStats`, most-trained first: the same order
/// the server ranks automatic highlights by, so "Automatic" in the editor
/// previews exactly what the profile will show.
struct FirestoreHighlightCandidatesLoader: HighlightCandidatesLoader {

    let userId: String

    func candidates(limit: Int) async throws -> [ProfileHighlight] {
        let snapshot = try await Firestore.firestore()
            .collection("Users/\(userId)/ExerciseStats")
            .order(by: "setCount", descending: true)
            .limit(to: limit)
            .getDocuments()
        return snapshot.documents.compactMap {
            ProfileHighlight(highlightData: $0.data(), exerciseId: $0.documentID)
        }
    }
}
