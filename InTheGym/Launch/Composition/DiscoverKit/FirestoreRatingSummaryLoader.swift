//
//  FirestoreRatingSummaryLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Reads `ratingCount` / `ratingSum` off a subject's card. Both are written by
/// the rating Cloud Functions and absent until the first rating, which reads
/// as an empty summary rather than an error.
struct FirestoreRatingSummaryLoader: RatingSummaryLoader {

    func summary(for subject: DiscoverSubject) async throws -> RatingSummary {
        let snapshot = try await Firestore.firestore().document(subject.cardPath).getDocument()
        return RatingSummary(
            count: snapshot.get("ratingCount") as? Int ?? 0,
            sum: snapshot.get("ratingSum") as? Int ?? 0
        )
    }
}
