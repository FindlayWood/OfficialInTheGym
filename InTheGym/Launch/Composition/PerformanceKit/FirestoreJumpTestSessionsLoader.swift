//
//  FirestoreJumpTestSessionsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// Reads one test's sessions from `Users/{uid}/JumpTests`. Filtered on `kind`
/// alone and sorted by the screens, so no composite index is needed. Decoded per
/// document; one that cannot be read is skipped, the lesson of
/// `FirestoreWorkoutTemplateFetcher`.
struct FirestoreJumpTestSessionsLoader: JumpTestSessionsLoader {

    let userId: String

    func loadSessions(_ kind: JumpTestKind) async throws -> [JumpTestSession] {
        let snapshot = try await Firestore.firestore()
            .collection(JumpTestPath.sessions(of: userId))
            .whereField("kind", isEqualTo: kind.rawValue)
            .getDocuments()
        return snapshot.documents.compactMap { document in
            guard let session = JumpTestFields.session(from: document) else {
                print("❌ Skipping jump test \(document.documentID)")
                return nil
            }
            return session
        }
    }
}
