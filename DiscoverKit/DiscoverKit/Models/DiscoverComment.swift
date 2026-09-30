//
//  DiscoverComment.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// A comment on an exercise, workout or clip — or a reply to one, when
/// `parentId` is set. Replies go one level deep.
///
/// **No text is ever edited.** The only change a comment goes through after
/// posting is its status: `removed` when its author deletes it (text cleared,
/// the document kept so replies under it still make sense), `hidden` when
/// moderation takes it down. Hidden comments are never loaded.
///
/// The counts are server-owned and optional — a new comment has none. They
/// are `var` only so the screen can reflect a like or a reply before the
/// Cloud Function recounts; nothing writes them back.
public struct DiscoverComment: Decodable, Identifiable, Hashable, Sendable {
    public let commentId: String
    public let authorId: String?
    public internal(set) var text: String
    public let parentId: String?
    public internal(set) var status: String
    public internal(set) var likeCount: Int?
    public internal(set) var replyCount: Int?
    public let createdAt: Date?

    public var id: String { commentId }

    public init(
        commentId: String,
        authorId: String?,
        text: String,
        parentId: String?,
        status: String = "visible",
        likeCount: Int? = nil,
        replyCount: Int? = nil,
        createdAt: Date?
    ) {
        self.commentId = commentId
        self.authorId = authorId
        self.text = text
        self.parentId = parentId
        self.status = status
        self.likeCount = likeCount
        self.replyCount = replyCount
        self.createdAt = createdAt
    }

    var isRemoved: Bool { status == "removed" }
    var isReply: Bool { parentId != nil }
}
