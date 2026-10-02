//
//  TaggedExercisesLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// The exercises a tag is visible on, most-voted first, a page at a time. The
/// cursor is the last entry of the previous page.
public protocol TaggedExercisesLoader {
    func exercises(taggedWith tag: String, limit: Int, after last: DiscoverTagged<DiscoverExerciseCard>?) async throws -> [DiscoverTagged<DiscoverExerciseCard>]
}
