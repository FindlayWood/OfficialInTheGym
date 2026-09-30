//
//  ReplyLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// The replies to one comment, oldest first — a reply reads as an answer to
/// the one before it.
public protocol ReplyLoader {
    func replies(to commentId: String, on subject: DiscoverSubject) async throws -> [DiscoverComment]
}
