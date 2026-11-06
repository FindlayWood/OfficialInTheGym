//
//  SportSessionDeleter.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/11/2026.
//

import Foundation

/// Removes a sport session's own document when the session is taken off the day. The
/// counterpart to `SportSessionSaver`, and like it knows exactly one destination — a document
/// left behind would keep counting toward stats for a session the user can no longer see.
public protocol SportSessionDeleter {
    func delete(sessionId: String) async throws
}

struct PreviewSportSessionDeleter: SportSessionDeleter {
    func delete(sessionId: String) async throws {
        print("Deleting sport session: \(sessionId)")
    }
}
