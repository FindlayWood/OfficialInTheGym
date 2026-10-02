//
//  PreviewDiscoverExerciseCardLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Foundation

/// Preview conformer. Ships in the framework, not the test target, as
/// `PreviewExerciseLoader` does in StatsKit.
public final class PreviewDiscoverExerciseCardLoader: DiscoverExerciseCardLoader, @unchecked Sendable {
    public init() {}

    public func load(limit: Int, after last: DiscoverExerciseCard?) async throws -> [DiscoverExerciseCard] {
        Self.cards.previewPage(limit: limit, after: last)
    }

    static let cards: [DiscoverExerciseCard] = [
        ("bench-press", "Bench Press", "upper_body"), ("bulgarian-split-squat", "Bulgarian Split Squat", "lower_body"),
        ("calf-raise", "Calf Raise", "lower_body"), ("chest-fly", "Chest Fly", "upper_body"),
        ("deadlift", "Deadlift", "lower_body"), ("face-pull", "Face Pull", "upper_body"),
        ("hip-thrust", "Hip Thrust", "lower_body"), ("lat-pulldown", "Lat Pulldown", "upper_body"),
        ("overhead-press", "Overhead Press", "upper_body"), ("pull-up", "Pull Up", "upper_body"),
        ("push-up", "Push Up", "upper_body"), ("squat", "Squat", "lower_body")
    ].map { DiscoverExerciseCard(exerciseId: $0.0, name: $0.1, category: $0.2) }
}
