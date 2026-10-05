//
//  DiscoverSearchQuery.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import Foundation

/// **The one definition of what a search actually looks for.** Trimmed,
/// lowercased, and a leading "@" dropped — people type usernames the way they
/// see them written. Every card and profile carries a lowercase copy of the
/// field searched (`titleLower`, `nameLower`, `usernameLower`,
/// `displayNameLower`), so lowercasing here is what lets a Firestore prefix
/// range, which is case-sensitive, find "Back Squat" from "back".
///
/// Carried over from ProfileKit's people-only search, which this replaced.
enum DiscoverSearchQuery {

    static func normalized(_ text: String) -> String {
        var query = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.hasPrefix("@") { query.removeFirst() }
        return query
    }
}
