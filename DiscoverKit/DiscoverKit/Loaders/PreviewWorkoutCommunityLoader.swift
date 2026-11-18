//
//  PreviewWorkoutCommunityLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation

/// Preview conformer. Ships in the framework, as the card loaders' do.
public final class PreviewWorkoutCommunityLoader: WorkoutCommunityLoader, @unchecked Sendable {
    let community: DiscoverWorkoutCommunity?

    public init(
        community: DiscoverWorkoutCommunity? = DiscoverWorkoutCommunity(
            peopleCount: 14, sessionCount: 41, averageDurationSeconds: 3120, averageRPE: 7.2
        )
    ) {
        self.community = community
    }

    public func community(ofWorkout templateId: String) async throws -> DiscoverWorkoutCommunity? {
        community
    }
}
