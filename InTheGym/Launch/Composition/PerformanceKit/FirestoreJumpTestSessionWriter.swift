//
//  FirestoreJumpTestSessionWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// Writes a session to `Users/{uid}/JumpTests/{session.id}`. A plain
/// `setData` under the session's own id, so a retried save overwrites.
struct FirestoreJumpTestSessionWriter: JumpTestSessionWriter {

    let userId: String

    func write(_ session: JumpTestSession) async throws {
        try await Firestore.firestore()
            .collection(JumpTestPath.sessions(of: userId))
            .document(session.id)
            .setData(JumpTestFields.fields(of: session))
    }
}
