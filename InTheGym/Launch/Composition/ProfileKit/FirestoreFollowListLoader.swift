//
//  FirestoreFollowListLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import ProfileKit

/// One page of a follow list, **active follows only**, through the shared
/// `FollowsPageQuery`: by followee for followers, by follower for following.
///
/// The `status == active` filter is also what lets the query past the rules,
/// which allow anyone to list active follows and nothing else.
struct FirestoreFollowListLoader: FollowListLoader {

    func page(_ kind: FollowListKind, of userId: String, after cursor: FollowListCursor?, limit: Int) async throws -> [FollowListEntry] {
        let query = kind == .followers
            ? FollowsPageQuery(field: "followeeId", otherField: "followerId", status: "active")
            : FollowsPageQuery(field: "followerId", otherField: "followeeId", status: "active")
        return try await query.page(for: userId, after: cursor, limit: limit)
    }
}
