//
//  FirestoreInjuryFetcher.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import MyDayKit

/// Reads `Users/{userId}/Injuries`, including any made on another device.
final class FirestoreInjuryFetcher: InjuryFetching {

    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    func fetchAll() async throws -> [Injury] {
        let snapshot = try await Firestore.firestore()
            .collection("Users/\(userId)/Injuries")
            .getDocuments()

        // Per document: one that cannot decode must not empty the list.
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: Injury.self)
            } catch {
                print("❌ Skipping injury \(document.documentID): \(error)")
                return nil
            }
        }
    }
}
