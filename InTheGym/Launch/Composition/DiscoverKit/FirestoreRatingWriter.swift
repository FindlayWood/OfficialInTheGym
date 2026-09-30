//
//  FirestoreRatingWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Writes the signed-in user's rating to `{subject}/Ratings/{userId}`.
///
/// Runs in a transaction only so `createdAt` is written on the first rating and
/// never again — re-rating replaces the value and moves `updatedAt`, but when
/// someone first rated something is not changed by their changing their mind.
///
/// `authorId` duplicates the document id on purpose: a collection-group query
/// ("my ratings", account deletion) can filter on a field, not on a document id.
/// The counts on the card are the Cloud Function's job; this writes one path.
struct FirestoreRatingWriter: RatingWriter {

    let userId: String

    func setRating(_ rating: Int, for subject: DiscoverSubject) async throws {
        let db = Firestore.firestore()
        let ref = db.document(subject.ratingPath(userId: userId))
        _ = try await db.runTransaction { transaction, errorPointer in
            do {
                let existing = try transaction.getDocument(ref)
                var data: [String: Any] = [
                    "rating": rating,
                    "authorId": userId,
                    "updatedAt": FieldValue.serverTimestamp()
                ]
                if !existing.exists {
                    data["createdAt"] = FieldValue.serverTimestamp()
                }
                transaction.setData(data, forDocument: ref, merge: true)
            } catch {
                errorPointer?.pointee = error as NSError
            }
            return nil
        }
    }
}
