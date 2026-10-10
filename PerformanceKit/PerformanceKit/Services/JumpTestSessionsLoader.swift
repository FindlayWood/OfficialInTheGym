//
//  JumpTestSessionsLoader.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Every session of one jump test the athlete has saved, in no particular
/// order. Screens sort them themselves.
public protocol JumpTestSessionsLoader {
    func loadSessions(_ kind: JumpTestKind) async throws -> [JumpTestSession]
}
