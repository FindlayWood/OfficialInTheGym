//
//  FirestoreMaxVerticalJumpLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// Reads the athlete's best jump from `VerticalJump/{uid}`. A missing document
/// is no best yet, not an error.
struct FirestoreMaxVerticalJumpLoader: MaxVerticalJumpLoader {

    let userId: String

    func loadMax() async throws -> VerticalJump? {
        let document = try await Firestore.firestore()
            .document(VerticalJumpPath.best(of: userId))
            .getDocument()
        guard document.exists else { return nil }
        return VerticalJumpFields.jump(from: document)
    }
}
