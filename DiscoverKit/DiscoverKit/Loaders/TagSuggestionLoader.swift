//
//  TagSuggestionLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Existing tags beginning with what the user has typed — offered while
/// tagging, so people reuse "legs" rather than inventing "leg".
public protocol TagSuggestionLoader {
    func tags(startingWith prefix: String, limit: Int) async throws -> [DiscoverTag]
}
