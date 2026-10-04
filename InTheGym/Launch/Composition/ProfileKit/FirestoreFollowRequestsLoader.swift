//
//  FirestoreFollowRequestsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import ProfileKit

/// Requests waiting for the signed-in user: their **pending** follows, through
/// the shared `FollowsPageQuery`. The rules let the followee list these.
struct FirestoreFollowRequestsLoader: FollowRequestsLoader {

    let currentUserId: String
    private let query = FollowsPageQuery(field: "followeeId", otherField: "followerId", status: "pending")

    init(currentUserId: String) {
        self.currentUserId = currentUserId
    }

    func requests(after cursor: FollowListCursor?, limit: Int) async throws -> [FollowListEntry] {
        try await query.page(for: currentUserId, after: cursor, limit: limit)
    }
}
