//
//  FirestorePopularTagsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import FirebaseFirestore
import Foundation

/// The most-used visible tags, by how many public subjects show them.
struct FirestorePopularTagsLoader: PopularTagsLoader {

    func popularTags(limit: Int) async throws -> [DiscoverTag] {
        let query = Firestore.firestore()
            .collection(DiscoverTagPath.tags)
            .whereField("status", isEqualTo: "visible")
            .order(by: "totalCount", descending: true)
            .limit(to: limit)
        return try await DiscoverCardQuery.page(query, as: DiscoverTag.self)
    }
}
