//
//  PreviewCommentWriter.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Preview conformer that accepts every comment and stores nothing.
public final class PreviewCommentWriter: CommentWriter, CommentRemover, LikeWriter, ClipWatchRecorder, @unchecked Sendable {
    public init() {}

    public func postComment(_ text: String, replyingTo parentId: String?, on subject: DiscoverSubject) async throws -> DiscoverComment {
        DiscoverComment(commentId: UUID().uuidString, authorId: "u1", text: text, parentId: parentId, createdAt: .now)
    }

    public func removeComment(_ commentId: String, on subject: DiscoverSubject) async throws {}

    public func setLiked(_ liked: Bool, for target: DiscoverLikeTarget) async throws {}

    public func recordClipWatch(clipID: String, watchedMoreThanThreeSeconds: Bool, watchedFullVideo: Bool, closePosition: Double, loopCount: Int) {}
}
