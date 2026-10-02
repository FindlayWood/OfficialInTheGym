//
//  FirestoreMyRatingLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Reads the signed-in user's rating document. A missing document is "not
/// rated yet", not a failure.
struct FirestoreMyRatingLoader: MyRatingLoader {

    let userId: String

    func myRating(for subject: DiscoverSubject) async throws -> Int? {
        let snapshot = try await Firestore.firestore().document(subject.ratingPath(userId: userId)).getDocument()
        return snapshot.get("rating") as? Int
    }
}
