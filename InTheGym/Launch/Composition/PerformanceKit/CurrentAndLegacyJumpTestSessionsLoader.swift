//
//  CurrentAndLegacyJumpTestSessionsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import PerformanceKit

/// Every session of a test: the jump engine's, and those saved before it. It
/// knows no paths; each loader it wraps knows one.
///
/// **A failed legacy read is not a failure.** The legacy history is the past;
/// losing it for a moment must not hide a session the athlete has just saved.
/// A failed current read is, because then nothing can be trusted to be complete.
struct CurrentAndLegacyJumpTestSessionsLoader: JumpTestSessionsLoader {

    let current: JumpTestSessionsLoader
    let legacy: JumpTestSessionsLoader

    func loadSessions(_ kind: JumpTestKind) async throws -> [JumpTestSession] {
        async let legacySessions = legacy.loadSessions(kind)
        let currentSessions = try await current.loadSessions(kind)
        do {
            return currentSessions + (try await legacySessions)
        } catch {
            print("❌ Legacy \(kind.rawValue) read failed: \(error)")
            return currentSessions
        }
    }
}
