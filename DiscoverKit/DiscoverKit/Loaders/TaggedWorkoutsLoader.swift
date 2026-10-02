//
//  TaggedWorkoutsLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// The public workouts a tag is visible on, most-voted first, a page at a time.
public protocol TaggedWorkoutsLoader {
    func workouts(taggedWith tag: String, limit: Int, after last: DiscoverTagged<DiscoverWorkoutCard>?) async throws -> [DiscoverTagged<DiscoverWorkoutCard>]
}
