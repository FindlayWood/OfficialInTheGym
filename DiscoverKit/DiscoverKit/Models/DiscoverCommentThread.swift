//
//  DiscoverCommentThread.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// A top-level comment and, once opened, its replies. Replies are fetched on
/// demand — most threads are never opened, and loading every reply with the
/// page would multiply its cost for nothing.
struct DiscoverCommentThread: Identifiable, Hashable {
    var comment: DiscoverComment
    var replies: [DiscoverComment] = []
    var isExpanded = false
    var isLoadingReplies = false

    var id: String { comment.id }

    /// A comment its author removed stays only while replies hang off it —
    /// without them, "Comment removed" is a row saying nothing.
    var isShown: Bool {
        !comment.isRemoved || (comment.replyCount ?? 0) > 0 || !visibleReplies.isEmpty
    }

    /// A removed reply has nothing under it, so it simply goes.
    var visibleReplies: [DiscoverComment] {
        replies.filter { !$0.isRemoved }
    }
}
