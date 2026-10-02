//
//  DiscoverExerciseCardLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Foundation

/// Loads exercise cards alphabetically, a page at a time. The cursor is the
/// last card of the previous page, for the reason given on
/// `DiscoverWorkoutCardLoader`.
public protocol DiscoverExerciseCardLoader {
    func load(limit: Int, after last: DiscoverExerciseCard?) async throws -> [DiscoverExerciseCard]
}
