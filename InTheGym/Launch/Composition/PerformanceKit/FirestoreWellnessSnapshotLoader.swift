//
//  FirestoreWellnessSnapshotLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// Reads the athlete's last wellness check-in from `WellnessScores/{uid}`,
/// through the legacy model. Missing or unreadable is nil, never an error: a
/// tracked session is recorded without it, as it always was. Nothing writes
/// this document now that the Wellness tool is out of the menu.
struct FirestoreWellnessSnapshotLoader: WellnessSnapshotLoader {

    let userId: String

    func loadWellness() async -> WellnessSnapshot? {
        do {
            let model = try await Firestore.firestore()
                .collection("WellnessScores")
                .document(userId)
                .getDocument(as: WellnessAnswersModel.self)
            return WellnessSnapshot(legacy: model)
        } catch {
            return nil
        }
    }
}
