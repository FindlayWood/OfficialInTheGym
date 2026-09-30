//
//  CommentWriterSpy.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation
@testable import DiscoverKit

/// Records every post and removal. Never asserts — the test does.
final class CommentWriterSpy: CommentWriter, CommentRemover, @unchecked Sendable {

    enum Message: Equatable {
        case post(String, parentId: String?)
        case remove(String)
    }

    private(set) var receivedMessages: [Message] = []
    var error: Error?

    func postComment(_ text: String, replyingTo parentId: String?, on subject: DiscoverSubject) async throws -> DiscoverComment {
        receivedMessages.append(.post(text, parentId: parentId))
        if let error { throw error }
        return DiscoverComment(commentId: "new-\(receivedMessages.count)", authorId: "me", text: text, parentId: parentId, createdAt: Date())
    }

    func removeComment(_ commentId: String, on subject: DiscoverSubject) async throws {
        receivedMessages.append(.remove(commentId))
        if let error { throw error }
    }
}
