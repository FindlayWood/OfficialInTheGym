//
//  PreviewDiscoverClipCardLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Foundation

/// Preview conformer. Ships in the framework, not the test target, as
/// `PreviewExerciseLoader` does in StatsKit.
public final class PreviewDiscoverClipCardLoader: DiscoverClipCardLoader, @unchecked Sendable {
    public init() {}

    public func load(limit: Int, after last: DiscoverClipCard?) async throws -> [DiscoverClipCard] {
        Self.cards.previewPage(limit: limit, after: last)
    }

    static let cards: [DiscoverClipCard] = (0..<18).map { index in
        DiscoverClipCard(
            clipId: "clip-\(index)",
            exerciseId: "squat",
            exerciseName: ["Squat", "Deadlift", "Bench Press", "Pull Up"][index % 4],
            videoURL: nil,
            thumbnailURL: nil,
            durationSeconds: Double(8 + index),
            createdBy: "user-\(index % 3)",
            uploadedAt: Date(timeIntervalSinceNow: -Double(index) * 3_600)
        )
    }
}
