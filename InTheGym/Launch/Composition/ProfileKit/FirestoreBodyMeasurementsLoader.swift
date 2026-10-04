//
//  FirestoreBodyMeasurementsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import ProfileKit

/// Reads height, height unit, date of birth and weight unit off the signed-in
/// user's own `Users/{uid}`. That is the one `Users` read the rules still allow
/// once others are closed out (`PROFILE_PLAN.md` step 2).
///
/// By hand rather than through the app's `Users` model, which has no body
/// fields and is decoded from two stores. Every field is optional, as
/// `createAccount` only writes the ones the user answered, and a malformed
/// value reads as "not set" rather than failing the screen.
struct FirestoreBodyMeasurementsLoader: BodyMeasurementsLoader {

    let userId: String

    func load() async throws -> BodyMeasurements {
        let snapshot = try await Firestore.firestore().document("Users/\(userId)").getDocument()
        return BodyMeasurements(
            heightCentimetres: snapshot.get("heightCentimetres") as? Double,
            heightUnit: (snapshot.get("heightUnit") as? String).flatMap(ProfileHeightUnit.init(rawValue:)),
            dateOfBirth: (snapshot.get("dateOfBirth") as? Timestamp)?.dateValue(),
            weightUnit: (snapshot.get("weightUnit") as? String).flatMap(ProfileWeightUnit.init(rawValue:))
        )
    }
}
