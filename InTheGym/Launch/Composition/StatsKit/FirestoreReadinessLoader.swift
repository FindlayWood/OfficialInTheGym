//
//  FirestoreReadinessLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import StatsKit

/// Reads `Users/{userId}/Readiness` — the per-day projection the readinessFromMyDay function
/// writes from each MyDay day — over the last `StatsHistoryWindow.days`, oldest first.
///
/// **A range on the `date` key, not a timestamp.** The documents are keyed and dated by the
/// user's own day as `yyyy-MM-dd`, which sorts as text in date order, so the range needs no
/// composite index. Decodes per document, as the other loaders do.
struct FirestoreReadinessLoader: ReadinessProviding {

    let userId: String

    func fetchReadiness() async throws -> [ReadinessDay] {
        let cutoff = StatsDay.key(daysAgo: StatsHistoryWindow.days)
        let snapshot = try await Firestore.firestore()
            .collection("Users/\(userId)/Readiness")
            .whereField("date", isGreaterThanOrEqualTo: cutoff)
            .order(by: "date")
            .getDocuments()

        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: ReadinessDay.self)
            } catch {
                print("❌ Skipping readiness \(document.documentID): \(error)")
                return nil
            }
        }
    }
}
