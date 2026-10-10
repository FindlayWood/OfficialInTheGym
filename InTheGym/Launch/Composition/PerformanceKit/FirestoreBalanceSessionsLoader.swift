//
//  FirestoreBalanceSessionsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// Reads `Users/{uid}/BalanceTests`. Decoded per document; one that cannot be
/// read is skipped.
struct FirestoreBalanceSessionsLoader: BalanceSessionsLoader {

    let userId: String

    func loadBalanceSessions() async throws -> [BalanceSession] {
        let snapshot = try await Firestore.firestore()
            .collection(BalanceTestPath.sessions(of: userId))
            .getDocuments()
        return snapshot.documents.compactMap { document in
            guard let session = BalanceTestFields.session(from: document) else {
                print("❌ Skipping balance test \(document.documentID)")
                return nil
            }
            return session
        }
    }
}
