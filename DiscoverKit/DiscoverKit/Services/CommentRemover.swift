//
//  CommentRemover.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Removes one of the signed-in user's own comments — a soft delete: its text
/// is cleared and its status becomes `removed`, so replies under it keep a
/// parent. The document itself is never deleted from the client.
public protocol CommentRemover {
    func removeComment(_ commentId: String, on subject: DiscoverSubject) async throws
}
