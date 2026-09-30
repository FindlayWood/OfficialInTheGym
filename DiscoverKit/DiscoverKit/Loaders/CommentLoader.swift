//
//  CommentLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Top-level comments on a subject, newest first, a page at a time — the
/// cursor is the last comment of the previous page, as the card loaders'
/// is. Includes removed comments (their replies still need a parent to hang
/// from); never hidden ones.
public protocol CommentLoader {
    func topLevelComments(on subject: DiscoverSubject, limit: Int, after last: DiscoverComment?) async throws -> [DiscoverComment]
}
