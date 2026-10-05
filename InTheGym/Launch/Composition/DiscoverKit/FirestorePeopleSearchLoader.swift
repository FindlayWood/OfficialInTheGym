//
//  FirestorePeopleSearchLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore

/// Prefix search over `Profiles`: `usernameLower` and `displayNameLower` each
/// matched as `>= query` and `< query + "\u{f8ff}"` (`DiscoverSearchPrefix`).
/// Both fields are written lowercase by `syncProfile`. Moved from ProfileKit's
/// `FirestoreUserSearchLoader` when search moved to DISCOVER.
///
/// Profiles moderation has hidden are dropped from the results here, after the
/// query. Filtering on `status` in the query would need a composite index per
/// field for a rare case.
///
/// Two queries in parallel, merged: **username matches first**, since someone
/// typing a handle wants that exact person, then display-name matches not
/// already found. Single-field range queries run on Firestore's automatic
/// indexes, so this needs no composite index.
struct FirestorePeopleSearchLoader: PeopleSearchLoader {

    func people(matching query: String, limit: Int) async throws -> [DiscoverUserProfile] {
        let profiles = Firestore.firestore().collection("Profiles")

        async let byUsername = DiscoverSearchPrefix.matching(query, on: "usernameLower", in: profiles)
            .limit(to: limit)
            .getDocuments()
        async let byName = DiscoverSearchPrefix.matching(query, on: "displayNameLower", in: profiles)
            .limit(to: limit)
            .getDocuments()

        let (usernames, names) = try await (byUsername, byName)
        var seen = Set<String>()
        return (usernames.documents + names.documents).compactMap { document in
            guard document.get("status") as? String != "hidden",
                  seen.insert(document.documentID).inserted else { return nil }
            return DiscoverUserProfile(
                userId: document.documentID,
                username: document.get("username") as? String ?? "",
                displayName: document.get("displayName") as? String ?? ""
            )
        }
        .prefix(limit)
        .map { $0 }
    }
}
