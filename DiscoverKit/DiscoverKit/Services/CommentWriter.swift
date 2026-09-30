//
//  CommentWriter.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Posts a comment, or a reply when `parentId` is set, as the signed-in user,
/// and returns it as written so the screen can show it without re-reading.
public protocol CommentWriter {
    func postComment(_ text: String, replyingTo parentId: String?, on subject: DiscoverSubject) async throws -> DiscoverComment
}
