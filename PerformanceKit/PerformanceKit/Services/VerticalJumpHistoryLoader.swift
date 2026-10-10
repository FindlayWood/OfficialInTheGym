//
//  VerticalJumpHistoryLoader.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// Every jump the athlete has saved, in no particular order. The history screen
/// sorts them itself, by date or by height.
public protocol VerticalJumpHistoryLoader {
    func loadJumps() async throws -> [VerticalJump]
}
