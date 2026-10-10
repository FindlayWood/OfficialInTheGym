//
//  JumpTestSession+TestHelpers.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation
@testable import PerformanceKit

extension JumpTestSession {

    /// A Vertical Jump session `daysAgo` before `Date.fixed`, one attempt per
    /// height given.
    static func make(id: String = UUID().uuidString, daysAgo: Double = 0, heights: [Double]) -> JumpTestSession {
        JumpTestSession(
            id: id,
            kind: .verticalJump,
            date: Date.fixed.addingTimeInterval(-daysAgo * 86_400),
            attempts: heights.map { JumpAttempt(height: $0, flightTime: nil, contactTime: nil) }
        )
    }
}
