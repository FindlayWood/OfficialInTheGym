//
//  FirestoreBodyMeasurementsWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Writes height, height unit and date of birth to `Users/{uid}`, and nothing
/// else. A `nil` **deletes** the field, because Clear has to reach the server,
/// and a missing field is what "not set" already means for every account that
/// skipped the question at signup.
///
/// `updateData` of these three keys only. The `Users/{userId}` update rule
/// allows exactly them alongside step 3's `displayName` / `bio`
/// (`PROFILE_PLAN.md` step 4). `weightKilograms` and `weightUnit` are never
/// written here; `syncLatestWeight` keeps them from the weight log.
struct FirestoreBodyMeasurementsWriter: BodyMeasurementsWriter {

    let userId: String

    func save(_ measurements: BodyMeasurements) async throws {
        try await Firestore.firestore().document("Users/\(userId)").updateData([
            "heightCentimetres": valueOrDelete(measurements.heightCentimetres),
            "heightUnit": valueOrDelete(measurements.heightUnit?.rawValue),
            "dateOfBirth": valueOrDelete(measurements.dateOfBirth.map(Timestamp.init(date:)))
        ])
    }

    private func valueOrDelete(_ value: Any?) -> Any {
        value ?? FieldValue.delete()
    }
}
