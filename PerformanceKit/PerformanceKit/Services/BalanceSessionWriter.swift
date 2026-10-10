//
//  BalanceSessionWriter.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Saves a finished balance session under its own `id`, so saving again
/// overwrites rather than duplicates.
public protocol BalanceSessionWriter {
    func write(_ session: BalanceSession) async throws
}
