//
//  TrackedSessionsLoader.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The athlete's recorded matches or practices, in no particular order. The
/// screen sorts them newest first.
public protocol TrackedSessionsLoader {
    func loadSessions(_ kind: TrackedSessionKind) async throws -> [TrackedSession]
}
