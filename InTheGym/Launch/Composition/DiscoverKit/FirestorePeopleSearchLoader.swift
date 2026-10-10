//
//  FirestorePeopleSearchLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore

/// People search over `Profiles`, two queries in parallel, merged with
/// **username matches first** — someone typing a handle wants that exact
/// person:
///
/// 1. `usernameLower` as a prefix range (`DiscoverSearchPrefix`) on the whole
///    query, so a handle with punctuation in it ("f_wood") still finds its
///    owner by exactly what was typed.
/// 2. `searchTokens` — every prefix of every word of the display name and
///    username, written by `syncProfile` — for the query's longest word, so
///    "wood" finds Findlay Wood. Any other words are checked here
///    (`DiscoverSearchQuery.matches`). Moved from ProfileKit's
///    `FirestoreUserSearchLoader` when search moved to DISCOVER, and from a
///    `displayNameLower` prefix range when search stopped matching only the
///    first word.
///
/// Profiles moderation has hidden are dropped here, after the query. Filtering
/// on `status` in the query would need a composite index for a rare case. Both
/// queries are single-field — a range, and an `array-contains` — so neither
/// needs a composite index.
struct FirestorePeopleSearchLoader: PeopleSearchLoader {

    /// How many more profiles to fetch when other words still have to be checked.
    private static let multiWordOverfetch = 4

    func people(matching query: String, limit: Int) async throws -> [DiscoverUserProfile] {
        let profiles = Firestore.firestore().collection("Profiles")
        let words = DiscoverSearchQuery.words(query)
        guard let token = DiscoverSearchQuery.lookupToken(for: words) else { return [] }

        async let byUsername = DiscoverSearchPrefix.matching(query, on: "usernameLower", in: profiles)
            .limit(to: limit)
            .getDocuments()
        async let byWord = profiles
            .whereField("searchTokens", arrayContains: token)
            .limit(to: words.count > 1 ? limit * Self.multiWordOverfetch : limit)
            .getDocuments()

        let (usernames, named) = try await (byUsername, byWord)
        var seen = Set<String>()
        let usernameMatches = usernames.documents.compactMap(profile)
        let wordMatches = named.documents.compactMap(profile).filter {
            DiscoverSearchQuery.matches(words, in: [$0.displayName, $0.username])
        }
        return (usernameMatches + wordMatches)
            .filter { seen.insert($0.userId).inserted }
            .prefix(limit)
            .map { $0 }
    }

    /// A profile as search lists it, or nil for one moderation has hidden.
    private func profile(_ document: QueryDocumentSnapshot) -> DiscoverUserProfile? {
        guard document.get("status") as? String != "hidden" else { return nil }
        return DiscoverUserProfile(
            userId: document.documentID,
            username: document.get("username") as? String ?? "",
            displayName: document.get("displayName") as? String ?? ""
        )
    }
}
