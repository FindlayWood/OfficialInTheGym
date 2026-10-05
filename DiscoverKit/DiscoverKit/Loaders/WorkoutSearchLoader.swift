//
//  WorkoutSearchLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import Foundation

/// Public, visible workout cards whose title **starts with** `query`, already
/// normalised by `DiscoverSearchQuery`. Prefix only, for the reason given on
/// `PeopleSearchLoader`. The query must carry the `isPublic` and `status`
/// filters every workout card query carries, or the rules reject it.
public protocol WorkoutSearchLoader {
    func workouts(matching query: String, limit: Int) async throws -> [DiscoverWorkoutCard]
}
