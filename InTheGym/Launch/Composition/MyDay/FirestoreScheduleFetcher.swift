//
//  FirestoreScheduleFetcher.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import MyDayKit

/// Reads `Users/{userId}/Schedules`, including any made on another device.
final class FirestoreScheduleFetcher: ScheduleFetching {

    private let userId: String

    init(userId: String) {
        self.userId = userId
    }

    func fetchAll() async throws -> [Schedule] {
        let snapshot = try await Firestore.firestore()
            .collection("Users/\(userId)/Schedules")
            .getDocuments()

        // Per document: one that cannot decode must not empty the list.
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: Schedule.self)
            } catch {
                print("❌ Skipping schedule \(document.documentID): \(error)")
                return nil
            }
        }
    }
}
