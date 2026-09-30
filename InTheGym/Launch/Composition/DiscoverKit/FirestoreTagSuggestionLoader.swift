//
//  FirestoreTagSuggestionLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// Tags beginning with `prefix` — a range over the `tag` field, which is how
/// Firestore does "starts with". Reordered by use afterwards, since the range
/// query can only order by the field it ranges over; tags used nowhere any
/// more are dropped rather than suggested.
struct FirestoreTagSuggestionLoader: TagSuggestionLoader {

    func tags(startingWith prefix: String, limit: Int) async throws -> [DiscoverTag] {
        guard !prefix.isEmpty else { return [] }
        let query = Firestore.firestore()
            .collection(DiscoverTagPath.tags)
            .whereField("status", isEqualTo: "visible")
            .whereField("tag", isGreaterThanOrEqualTo: prefix)
            .whereField("tag", isLessThan: prefix + "\u{f8ff}")
            .order(by: "tag")
            .limit(to: limit * 2)
        let tags = try await DiscoverCardQuery.page(query, as: DiscoverTag.self)
        return Array(
            tags.filter { ($0.totalCount ?? 0) > 0 }
                .sorted { ($0.totalCount ?? 0) > ($1.totalCount ?? 0) }
                .prefix(limit)
        )
    }
}
