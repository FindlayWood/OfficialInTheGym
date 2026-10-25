//
//  FirestoreCustomExerciseFetcher.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import MyDayKit

/// Reads `Users/{userId}/CustomExercises` — the creator's copies, including
/// any made on another device and the `status` the server mirrors onto them.
/// Never the top-level `CustomExercises`, which is the review queue.
final class FirestoreCustomExerciseFetcher: CustomExerciseFetching {

    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    func fetchAll() async throws -> [CustomExercise] {
        let snapshot = try await Firestore.firestore()
            .collection("Users/\(userId)/CustomExercises")
            .getDocuments()

        // Per document: one that cannot decode must not empty the list.
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: CustomExercise.self)
            } catch {
                print("❌ Skipping custom exercise \(document.documentID): \(error)")
                return nil
            }
        }
    }
}
