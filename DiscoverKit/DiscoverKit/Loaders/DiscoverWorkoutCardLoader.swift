//
//  DiscoverWorkoutCardLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Foundation

/// Loads public workout cards, newest first, a page at a time.
///
/// **The cursor is the last card of the previous page, not a Firestore
/// snapshot.** The card already carries the fields the ordering is on
/// (`createdAt`, then id), so the adapter can resume after it without the
/// framework ever seeing a query type. `nil` means the first page.
public protocol DiscoverWorkoutCardLoader {
    func load(limit: Int, after last: DiscoverWorkoutCard?) async throws -> [DiscoverWorkoutCard]
}
