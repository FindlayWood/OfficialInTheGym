//
//  FirestoreWeightEntryWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Writes one day's entry to `Users/{uid}/WeightTracking/{yyyy-MM-dd}` in the
/// shape `createAccount` writes the signup entry: `id`, `date` (UTC
/// midnight), `createdDate`, `weightKilograms`, and `weightUnit` when known.
/// A plain `setData` replaces the day's earlier entry, which is the
/// one-per-day rule. The server copies the newest entry onto `Users/{uid}`.
struct FirestoreWeightEntryWriter: WeightEntryWriter {

    let userId: String

    func log(_ entry: WeightEntry) async throws {
        var data: [String: Any] = [
            "id": entry.id,
            "date": Timestamp(date: entry.date),
            "createdDate": FieldValue.serverTimestamp(),
            "weightKilograms": entry.weightKilograms
        ]
        if let unit = entry.unit {
            data["weightUnit"] = unit.rawValue
        }
        try await Firestore.firestore().document(WeightTrackingPath.entry(entry.id, of: userId)).setData(data)
    }
}
