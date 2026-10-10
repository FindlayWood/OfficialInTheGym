//
//  WorkoutSearchLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import Foundation

/// Public, visible workout cards where **every word of `query` starts some
/// word of the title** (`DiscoverSearchQuery.matches`) — "upper" finds
/// "Saturday Upper". `query` arrives normalised by `DiscoverSearchQuery`.
/// Answered from the server's `searchTokens`; matching inside a word is not
/// possible there. The query must carry the `isPublic` and `status`
/// filters every workout card query carries, or the rules reject it.
public protocol WorkoutSearchLoader {
    func workouts(matching query: String, limit: Int) async throws -> [DiscoverWorkoutCard]
}
