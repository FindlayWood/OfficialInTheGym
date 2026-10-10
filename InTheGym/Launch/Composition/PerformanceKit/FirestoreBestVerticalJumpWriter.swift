//
//  FirestoreBestVerticalJumpWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// Overwrites `VerticalJump/{uid}` with the athlete's best, `save.best`, which
/// is the old best when the new jump did not beat it.
struct FirestoreBestVerticalJumpWriter: VerticalJumpWriter {

    let userId: String

    func write(_ save: VerticalJumpSave) async throws {
        try await Firestore.firestore()
            .document(VerticalJumpPath.best(of: userId))
            .setData(VerticalJumpFields.fields(of: save.best))
    }
}
