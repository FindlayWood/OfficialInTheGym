//
//  WorkloadWriter.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Adds an entry to the athlete's workload log. The entry's `id` is ignored:
/// the store mints one.
public protocol WorkloadWriter {
    func write(_ workload: Workload) async throws
}
