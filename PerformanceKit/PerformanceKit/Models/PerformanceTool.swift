//
//  PerformanceTool.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The tests on the PERFORMANCE tab, in the order the home screen lists them.
///
/// Vertical Jump is the one test today. CMJ, the weekly fatigue check, drop
/// jump, single-leg and repeated jumps, and balance join it phase by phase
/// (`PERFORMANCE_PLAN.md`, part 2). Workload, Journal, Match Tracker and
/// Practice Tracker were retired in phase A.
///
/// `@frozen` because PerformanceKit builds with library evolution. Without it,
/// every `switch` over a tool in the app needs an `@unknown default`.
@frozen
public enum PerformanceTool: CaseIterable, Sendable {
    case verticalJump

    var title: String {
        switch self {
        case .verticalJump: "Vertical Jump"
        }
    }

    var message: String {
        switch self {
        case .verticalJump: "Jump height with arm swing, measured on camera."
        }
    }

    /// The SF Symbol on the tool's tile.
    var systemImage: String {
        switch self {
        case .verticalJump: "arrow.up.to.line"
        }
    }
}
