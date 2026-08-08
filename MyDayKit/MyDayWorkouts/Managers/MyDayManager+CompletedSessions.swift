//
//  MyDayManager+CompletedSessions.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/08/2026.
//

import Foundation

extension MyDayManager {

    /// Persist a finished session as a document of its own.
    ///
    /// The session is already in the day document; this is the copy that makes
    /// it findable without reading every day the user has.
    func saveCompletedSession(_ session: CompletedWorkoutSession) {
        Task {
            try await completedSessionSaver.save(session)
        }
    }

    /// Remove the session documents for a workout being taken off the day.
    ///
    /// Only a completed entry has any — a session that was never finished was
    /// never written. This is the only path that reaches them, since cancelling
    /// is unavailable once a session is completed.
    func deleteCompletedSession(for entry: DailyWorkoutEntry) {
        guard entry.status == .completed, let record = entry.sessionRecord else { return }
        Task {
            try await completedSessionDeleter.delete(sessionId: record.id)
        }
    }
}
