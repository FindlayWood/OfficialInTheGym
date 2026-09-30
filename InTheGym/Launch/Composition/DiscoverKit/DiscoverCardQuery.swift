//
//  DiscoverCardQuery.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation


/// Runs one page of a DISCOVER card query and decodes it **per document**,
/// skipping and logging any card that fails rather than failing the page —
/// the rule `FirestoreWorkoutTemplateFetcher` learned when one undecodable
/// template blanked the whole library.
///
/// Every card query ends in a document-id ordering after its main field, so
/// two cards sharing a `createdAt` (or a name) still page in a fixed order and
/// the cursor can never skip or repeat one.
enum DiscoverCardQuery {

    static func page<Card: Decodable>(_ query: Query, as type: Card.Type) async throws -> [Card] {
        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: Card.self)
            } catch {
                print("❌ Skipping Discover card \(document.reference.path): \(error)")
                return nil
            }
        }
    }

    /// A cursor value for a date field that may be absent: Firestore orders a
    /// `null` field, so `NSNull` resumes after it where a missing value could not.
    static func cursorValue(_ date: Date?) -> Any {
        date.map(Timestamp.init(date:)) ?? NSNull()
    }
}
