//
//  FirestoreVerticalJumpResultWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// Adds the saved jump to `VerticalJump/{uid}/Results`, under a new document
/// id, as the legacy batch did. It writes `save.jump` only. The best is the
/// other writer's.
struct FirestoreVerticalJumpResultWriter: VerticalJumpWriter {

    let userId: String

    func write(_ save: VerticalJumpSave) async throws {
        try await Firestore.firestore()
            .collection(VerticalJumpPath.results(of: userId))
            .document()
            .setData(VerticalJumpFields.fields(of: save.jump))
    }
}
