//
//  FirestoreBodyMassLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// The athlete's latest weight, read from `Users/{uid}.weightKilograms`.
///
/// That field **is** the latest weight: the `syncLatestWeight` function copies
/// the newest `WeightTracking` entry onto it, so reading it here is reading the
/// weight log without a second definition of "latest". `CLAUDE.md` names this
/// as what bodyweight-relative figures should read. Missing (no weight ever
/// logged) is nil.
///
/// `Users/{uid}` is private to its owner, so this is the athlete reading their
/// own. A coach's view will need the weight on the athlete's shared summary.
struct FirestoreBodyMassLoader: BodyMassLoader {

    let userId: String

    func loadBodyMass() async throws -> Double? {
        let document = try await Firestore.firestore()
            .collection("Users")
            .document(userId)
            .getDocument()
        guard let mass = (document.get("weightKilograms") as? NSNumber)?.doubleValue, mass > 0 else {
            return nil
        }
        return mass
    }
}
