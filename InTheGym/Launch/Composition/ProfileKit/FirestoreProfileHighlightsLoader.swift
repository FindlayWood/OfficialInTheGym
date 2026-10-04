//
//  FirestoreProfileHighlightsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Reads `ProfileHighlights/{uid}`, written only by the highlight functions.
/// For a private account the read rule allows only the owner and approved
/// followers. The profile screen asks only when it may show the result.
struct FirestoreProfileHighlightsLoader: ProfileHighlightsLoader {

    func highlights(for userId: String) async throws -> ProfileHighlights? {
        let snapshot = try await Firestore.firestore().document("ProfileHighlights/\(userId)").getDocument()
        guard snapshot.exists else { return nil }
        let raw = snapshot.get("highlights") as? [[String: Any]] ?? []
        return ProfileHighlights(
            highlights: raw.compactMap { ProfileHighlight(highlightData: $0) },
            isPinned: snapshot.get("isPinned") as? Bool == true
        )
    }
}
