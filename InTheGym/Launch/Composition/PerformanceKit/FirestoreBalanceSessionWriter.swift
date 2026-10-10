//
//  FirestoreBalanceSessionWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// Writes a balance session to `Users/{uid}/BalanceTests/{session.id}`, a
/// plain `setData` under its own id so a retried save overwrites.
struct FirestoreBalanceSessionWriter: BalanceSessionWriter {

    let userId: String

    func write(_ session: BalanceSession) async throws {
        try await Firestore.firestore()
            .collection(BalanceTestPath.sessions(of: userId))
            .document(session.id)
            .setData(BalanceTestFields.fields(of: session))
    }
}
