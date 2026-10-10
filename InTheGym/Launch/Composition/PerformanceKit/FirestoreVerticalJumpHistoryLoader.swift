//
//  FirestoreVerticalJumpHistoryLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// Reads every saved jump from `VerticalJump/{uid}/Results`. Decoded per
/// document, and a jump that cannot be read is skipped, as the legacy view
/// model already did.
struct FirestoreVerticalJumpHistoryLoader: VerticalJumpHistoryLoader {

    let userId: String

    func loadJumps() async throws -> [VerticalJump] {
        let snapshot = try await Firestore.firestore()
            .collection(VerticalJumpPath.results(of: userId))
            .getDocuments()
        return snapshot.documents.compactMap { document in
            guard let jump = VerticalJumpFields.jump(from: document) else {
                print("❌ Skipping jump \(document.documentID)")
                return nil
            }
            return jump
        }
    }
}
