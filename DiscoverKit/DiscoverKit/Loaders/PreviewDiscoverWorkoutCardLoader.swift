//
//  PreviewDiscoverWorkoutCardLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Foundation

/// Preview conformer. Ships in the framework, not the test target, as
/// `PreviewExerciseLoader` does in StatsKit.
public final class PreviewDiscoverWorkoutCardLoader: DiscoverWorkoutCardLoader, @unchecked Sendable {
    public init() {}

    public func load(limit: Int, after last: DiscoverWorkoutCard?) async throws -> [DiscoverWorkoutCard] {
        Self.cards.previewPage(limit: limit, after: last)
    }

    static let cards: [DiscoverWorkoutCard] = (0..<25).map { index in
        DiscoverWorkoutCard(
            templateId: "template-\(index)",
            title: ["Lower Body Strength", "Push Day", "Pull Day", "Full Body Circuit", "Upper Hypertrophy"][index % 5],
            createdBy: "user-\(index % 4)",
            exerciseCount: 3 + index % 5,
            createdAt: Date(timeIntervalSinceNow: -Double(index) * 86_400),
            isPublic: true
        )
    }
}
