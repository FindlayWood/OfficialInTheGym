//
//  DiscoverClipCardLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Foundation

/// Loads public clip cards, newest first, a page at a time. The cursor is the
/// last card of the previous page, for the reason given on
/// `DiscoverWorkoutCardLoader`.
public protocol DiscoverClipCardLoader {
    func load(limit: Int, after last: DiscoverClipCard?) async throws -> [DiscoverClipCard]
}
