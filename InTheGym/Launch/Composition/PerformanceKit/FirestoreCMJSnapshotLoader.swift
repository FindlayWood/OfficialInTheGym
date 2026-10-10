//
//  FirestoreCMJSnapshotLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// Reads the athlete's CMJ summary from `CMJ/{uid}`, through the legacy model.
/// Missing or unreadable is nil, never an error: a tracked session is recorded
/// without it, as it always was. Nothing writes this document now that the CMJ
/// tool is out of the menu.
struct FirestoreCMJSnapshotLoader: CMJSnapshotLoader {

    let userId: String

    func loadCMJ() async -> CMJSnapshot? {
        do {
            let model = try await Firestore.firestore()
                .collection("CMJ")
                .document(userId)
                .getDocument(as: CMJModel.self)
            return CMJSnapshot(legacy: model)
        } catch {
            return nil
        }
    }
}
