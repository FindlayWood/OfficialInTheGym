//
//  ProfileClip.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// One clip in a profile's grid: a public, visible `DiscoverClips` card, the
/// same card DISCOVER lists. It carries every field of that card so the app can
/// hand it to DISCOVER's clip player (likes, comments, report) without another
/// read.
public struct ProfileClip: Equatable, Identifiable, Sendable {
    public let clipId: String
    public let exerciseId: String?
    public let exerciseName: String?
    public let videoURL: String?
    public let thumbnailURL: String?
    public let durationSeconds: Double?
    public let createdBy: String?
    public let uploadedAt: Date?
    public let likeCount: Int?
    public let commentCount: Int?
    public let viewCount: Int?

    public var id: String { clipId }

    public init(
        clipId: String,
        exerciseId: String?,
        exerciseName: String?,
        videoURL: String?,
        thumbnailURL: String?,
        durationSeconds: Double?,
        createdBy: String?,
        uploadedAt: Date?,
        likeCount: Int?,
        commentCount: Int?,
        viewCount: Int?
    ) {
        self.clipId = clipId
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.durationSeconds = durationSeconds
        self.createdBy = createdBy
        self.uploadedAt = uploadedAt
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.viewCount = viewCount
    }

    var thumbnail: URL? { thumbnailURL.flatMap(URL.init(string:)) }

    /// "0:12", as DISCOVER's clip cards show it.
    var formattedDuration: String? {
        guard let durationSeconds else { return nil }
        let total = Int(durationSeconds.rounded())
        return "\(total / 60):" + String(format: "%02d", total % 60)
    }
}
