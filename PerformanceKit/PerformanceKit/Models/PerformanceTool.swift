//
//  PerformanceTool.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The tests on the PERFORMANCE tab, in the order the home screen lists them.
///
/// CMJ and Vertical Jump today. The weekly fatigue check, drop jump, single-leg
/// and repeated jumps, and balance join them phase by phase
/// (`PERFORMANCE_PLAN.md`, part 2). A jump test is a `JumpTestKind` on the
/// shared engine; `jumpTest` is that mapping.
///
/// `@frozen` because PerformanceKit builds with library evolution. Without it,
/// every `switch` over a tool in the app needs an `@unknown default`.
@frozen
public enum PerformanceTool: CaseIterable, Sendable {
    case cmj
    case verticalJump

    var jumpTest: JumpTestKind {
        switch self {
        case .cmj: .cmj
        case .verticalJump: .verticalJump
        }
    }

    var title: String { jumpTest.title }

    var message: String { jumpTest.summary }

    /// The SF Symbol on the tool's tile.
    var systemImage: String {
        switch self {
        case .cmj: "bolt.fill"
        case .verticalJump: "arrow.up.to.line"
        }
    }
}
