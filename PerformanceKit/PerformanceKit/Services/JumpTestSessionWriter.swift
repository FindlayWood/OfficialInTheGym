//
//  JumpTestSessionWriter.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Saves a finished session under its own `id`, so saving it again
/// overwrites rather than duplicates.
public protocol JumpTestSessionWriter {
    func write(_ session: JumpTestSession) async throws
}
