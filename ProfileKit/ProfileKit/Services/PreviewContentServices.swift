//
//  PreviewContentServices.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Preview conformer for highlights and clips: three highlights, a few clips
/// without thumbnails, and candidates to pin from.
public final class PreviewContentServices: ProfileHighlightsLoader, ProfileClipsLoader,
                                           HighlightCandidatesLoader, PinnedHighlightsWriter,
                                           @unchecked Sendable {
    public static let sample: [ProfileHighlight] = [
        ProfileHighlight(exerciseId: "squat", exerciseName: "Back Squat", maxWeightKilograms: 140, maxTimeSeconds: 0, isTimeBased: false),
        ProfileHighlight(exerciseId: "bench", exerciseName: "Bench Press", maxWeightKilograms: 102.5, maxTimeSeconds: 0, isTimeBased: false),
        ProfileHighlight(exerciseId: "plank", exerciseName: "Plank", maxWeightKilograms: 0, maxTimeSeconds: 150, isTimeBased: true)
    ]

    public init() {}

    public func highlights(for userId: String) async throws -> ProfileHighlights? {
        ProfileHighlights(highlights: Self.sample, isPinned: false)
    }

    public func clips(of userId: String, limit: Int) async throws -> [ProfileClip] {
        (0..<5).map {
            ProfileClip(
                clipId: "c\($0)", exerciseId: "squat", exerciseName: "Back Squat", videoURL: nil,
                thumbnailURL: nil, durationSeconds: 12, createdBy: userId, uploadedAt: .now,
                likeCount: $0, commentCount: 0, viewCount: 0
            )
        }
    }

    public func candidates(limit: Int) async throws -> [ProfileHighlight] {
        Self.sample + [
            ProfileHighlight(exerciseId: "curl", exerciseName: "Bicep Curl", maxWeightKilograms: 20, maxTimeSeconds: 0, isTimeBased: false)
        ]
    }

    public func setPinned(_ exerciseIds: [String]) async throws {}
}
