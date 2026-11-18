//
//  PreviewContentServices.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Preview conformer for clips: a few clips without thumbnails.
public final class PreviewContentServices: ProfileClipsLoader, @unchecked Sendable {

    public init() {}

    public func clips(of userId: String, limit: Int) async throws -> [ProfileClip] {
        (0..<5).map {
            ProfileClip(
                clipId: "c\($0)", exerciseId: "squat", exerciseName: "Back Squat", videoURL: nil,
                thumbnailURL: nil, durationSeconds: 12, createdBy: userId, uploadedAt: .now,
                likeCount: $0, commentCount: 0, viewCount: 0
            )
        }
    }
}
