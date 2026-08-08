//
//  CompletedWorkoutSessionSaver.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/08/2026.
//

import Foundation

/// Writes a finished session to both of its homes — the top-level analytics
/// collection and the user's own history. One call, because two copies that can
/// diverge are worse than one copy: the concrete implementation writes them in
/// a single batch.
public protocol CompletedWorkoutSessionSaver {
    func save(_ session: CompletedWorkoutSession) async throws
}

struct PreviewCompletedWorkoutSessionSaver: CompletedWorkoutSessionSaver {
    func save(_ session: CompletedWorkoutSession) async throws {
        print("Saving completed session: \(session.id)")
    }
}
