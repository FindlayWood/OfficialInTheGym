//
//  FirestoreWeightLogLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Reads the newest weight entries, ordered by `date` (UTC midnight, as both
/// `createAccount` and `FirestoreWeightEntryWriter` write it). Decoded per
/// document, and an entry that cannot be read is skipped rather than failing
/// the whole log, the lesson of `FirestoreWorkoutTemplateFetcher`.
struct FirestoreWeightLogLoader: WeightLogLoader {

    let userId: String

    func load(limit: Int) async throws -> [WeightEntry] {
        let snapshot = try await Firestore.firestore()
            .collection(WeightTrackingPath.entries(of: userId))
            .order(by: "date", descending: true)
            .limit(to: limit)
            .getDocuments()
        return snapshot.documents.compactMap { document in
            guard let date = (document.get("date") as? Timestamp)?.dateValue(),
                  let kilograms = document.get("weightKilograms") as? Double else {
                print("❌ Skipping weight entry \(document.documentID)")
                return nil
            }
            return WeightEntry(
                id: document.documentID,
                date: date,
                weightKilograms: kilograms,
                unit: (document.get("weightUnit") as? String).flatMap(ProfileWeightUnit.init(rawValue:))
            )
        }
    }
}
