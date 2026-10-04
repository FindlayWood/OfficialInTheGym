//
//  FirestorePinnedHighlightsWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Writes `Users/{uid}.pinnedHighlights`, or deletes it to go back to
/// automatic. `profileHighlightsFromPins` rebuilds `ProfileHighlights` from
/// it. The `Users` update rule's `hasOnly` gains `pinnedHighlights` in
/// step 8, as a list of at most three.
struct FirestorePinnedHighlightsWriter: PinnedHighlightsWriter {

    let userId: String

    func setPinned(_ exerciseIds: [String]) async throws {
        let value: Any = exerciseIds.isEmpty ? FieldValue.delete() : exerciseIds
        try await Firestore.firestore().document("Users/\(userId)").updateData(["pinnedHighlights": value])
    }
}
