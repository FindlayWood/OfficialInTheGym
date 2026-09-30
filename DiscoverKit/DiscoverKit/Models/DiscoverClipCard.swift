//
//  DiscoverClipCard.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Foundation

/// One clip as DISCOVER lists it — the server-owned `DiscoverClips/{id}` card.
///
/// **Nearly everything is optional**, because the card is assembled from
/// sources that do not all arrive together: the projection trigger writes the
/// clip's fields, `recordClipWatch` writes the view counts, and either can land
/// first. `thumbnailURL` in particular is `null` whenever thumbnail generation
/// failed at upload — the same gap that stopped MyDayKit's `Clip` decoding.
///
/// No rating and no tags: a clip is a user doing an exercise, and is found
/// through that exercise.
public struct DiscoverClipCard: Decodable, Identifiable, Hashable, Sendable {
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
        likeCount: Int? = nil,
        commentCount: Int? = nil,
        viewCount: Int? = nil
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

    /// Stored as the strings the card holds, parsed here, so decoding never
    /// depends on how a decoder chooses to represent `URL`.
    var thumbnail: URL? { thumbnailURL.flatMap(URL.init(string:)) }
    var video: URL? { videoURL.flatMap(URL.init(string:)) }

    /// `0:12` — a clip is seconds long, so minutes never need padding.
    var formattedDuration: String? {
        guard let durationSeconds else { return nil }
        let total = Int(durationSeconds.rounded())
        return "\(total / 60):" + String(format: "%02d", total % 60)
    }
}
