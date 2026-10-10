//
//  FirestoreWorkoutSearchLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore

/// Public, visible workout cards found by **any word of the title**, ordered by
/// `titleLower`.
///
/// One `array-contains` on `searchTokens` — every prefix of every title word,
/// written by the card projection (`WorkoutCard.ts`) — for the query's longest
/// word (`DiscoverSearchQuery.lookupToken`). Firestore allows one
/// `array-contains` per query, so with more than one word the rest are checked
/// here (`DiscoverSearchQuery.matches`), over a larger page so the check does
/// not leave the results short.
///
/// A card projected before `searchTokens` existed is not found until
/// `rebuildDiscoverCards` runs. Keeps the `isPublic` and `status` filters every
/// workout card query carries — the rules reject a query on another user's
/// cards without `isPublic` — so it needs a composite index: `isPublic` ↑,
/// `status` ↑, `searchTokens` (array-contains), `titleLower` ↑.
struct FirestoreWorkoutSearchLoader: WorkoutSearchLoader {

    /// How many more cards to fetch when other words still have to be checked.
    private static let multiWordOverfetch = 4

    func workouts(matching query: String, limit: Int) async throws -> [DiscoverWorkoutCard] {
        let words = DiscoverSearchQuery.words(query)
        guard let token = DiscoverSearchQuery.lookupToken(for: words) else { return [] }
        let search = Firestore.firestore()
            .collection("DiscoverWorkouts")
            .whereField("isPublic", isEqualTo: true)
            .whereField("status", isEqualTo: "visible")
            .whereField("searchTokens", arrayContains: token)
            .order(by: "titleLower")
            .limit(to: words.count > 1 ? limit * Self.multiWordOverfetch : limit)
        let cards = try await DiscoverCardQuery.page(search, as: DiscoverWorkoutCard.self)
        return Array(cards.filter { DiscoverSearchQuery.matches(words, in: [$0.title]) }.prefix(limit))
    }
}
