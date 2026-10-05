//
//  PeopleSearchLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import Foundation

/// People whose @username or display name **starts with** `query`, which
/// arrives already normalised by `DiscoverSearchQuery`. A prefix match, not a
/// substring one, because Firestore can only answer prefixes — and the start
/// of a name is also what people type.
///
/// Profiles moderation has hidden are the adapter's to drop. Blocked users are
/// not: blocking is on the device, so the screen filters them through
/// `DiscoverModerationStore` as every other DISCOVER list does.
public protocol PeopleSearchLoader {
    func people(matching query: String, limit: Int) async throws -> [DiscoverUserProfile]
}
