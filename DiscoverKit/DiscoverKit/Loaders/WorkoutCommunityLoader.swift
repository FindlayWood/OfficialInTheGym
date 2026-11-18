//
//  WorkoutCommunityLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation

/// Reads a workout's current community stats off its card.
///
/// The card a page was opened from is a snapshot of when its list loaded, and a page opened from a
/// profile is built from a profile row that carries none, so the page refreshes on appear, as
/// `RatingSummaryLoader` does. `nil` is a workout fewer than three people have done, not a failure.
public protocol WorkoutCommunityLoader {
    func community(ofWorkout templateId: String) async throws -> DiscoverWorkoutCommunity?
}
