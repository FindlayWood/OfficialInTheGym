//
//  TrackedSessionWriter.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Records a match or practice and delivers it back under the id it was stored
/// as. The `id` passed in is ignored: the store mints one, which the session's
/// workload entry then links to.
public protocol TrackedSessionWriter {
    func write(_ session: TrackedSession, kind: TrackedSessionKind) async throws -> TrackedSession
}
