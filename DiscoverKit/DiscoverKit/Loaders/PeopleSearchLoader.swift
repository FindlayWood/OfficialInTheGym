//
//  PeopleSearchLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import Foundation

/// People whose @username starts with `query`, or where every word of `query`
/// starts some word of their display name or username
/// (`DiscoverSearchQuery.matches`) — "wood" finds Findlay Wood. `query` arrives
/// normalised by `DiscoverSearchQuery`. Answered from the server's
/// `searchTokens`, so it matches the starts of words, never their middles.
///
/// Profiles moderation has hidden are the adapter's to drop. Blocked users are
/// not: blocking is on the device, so the screen filters them through
/// `DiscoverModerationStore` as every other DISCOVER list does.
public protocol PeopleSearchLoader {
    func people(matching query: String, limit: Int) async throws -> [DiscoverUserProfile]
}
