//
//  FirestoreWeightEntryRemover.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Deletes one weight entry. If it was the newest, `syncLatestWeight` falls
/// back to the one before it on the user document.
struct FirestoreWeightEntryRemover: WeightEntryRemover {

    let userId: String

    func remove(entryId: String) async throws {
        try await Firestore.firestore().document(WeightTrackingPath.entry(entryId, of: userId)).delete()
    }
}
