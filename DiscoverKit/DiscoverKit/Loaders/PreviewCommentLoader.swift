//
//  PreviewCommentLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Preview conformer holding a fixed set of comments, including a removed one
/// with replies — the case a comment screen most needs to be seen drawing.
public final class PreviewCommentLoader: CommentLoader, ReplyLoader, @unchecked Sendable {
    public init() {}

    public func topLevelComments(on subject: DiscoverSubject, limit: Int, after last: DiscoverComment?) async throws -> [DiscoverComment] {
        Self.topLevel.previewPage(limit: limit, after: last)
    }

    public func replies(to commentId: String, on subject: DiscoverSubject) async throws -> [DiscoverComment] {
        Self.replies.filter { $0.parentId == commentId }
    }

    static let topLevel: [DiscoverComment] = [
        DiscoverComment(commentId: "c1", authorId: "u1", text: "Brutal but worth it. Dropped the last set to 8 reps.", parentId: nil, likeCount: 4, replyCount: 2, createdAt: .now.addingTimeInterval(-3_600)),
        DiscoverComment(commentId: "c2", authorId: nil, text: "", parentId: nil, status: "removed", replyCount: 1, createdAt: .now.addingTimeInterval(-86_400)),
        DiscoverComment(commentId: "c3", authorId: "u3", text: "Good one for a hotel gym.", parentId: nil, createdAt: .now.addingTimeInterval(-172_800))
    ]

    static let replies: [DiscoverComment] = [
        DiscoverComment(commentId: "r1", authorId: "u2", text: "Same here.", parentId: "c1", createdAt: .now.addingTimeInterval(-1_800)),
        DiscoverComment(commentId: "r2", authorId: "u3", text: "Try it with a longer rest.", parentId: "c1", likeCount: 1, createdAt: .now.addingTimeInterval(-900)),
        DiscoverComment(commentId: "r3", authorId: "u1", text: "Still worth reading the reply.", parentId: "c2", createdAt: .now.addingTimeInterval(-3_600))
    ]
}
