//
//  PerformanceTool.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The tests on the PERFORMANCE tab, in the order the home screen lists them.
///
/// Five jump tests and balance
/// (`PERFORMANCE_PLAN.md`, part 2). A jump test is a `JumpTestKind` on the
/// shared engine (`jumpTest`); balance is its own test, measured with the
/// motion sensors rather than the camera.
///
/// `@frozen` because PerformanceKit builds with library evolution. Without it,
/// every `switch` over a tool in the app needs an `@unknown default`.
@frozen
public enum PerformanceTool: CaseIterable, Sendable {
    case cmj
    case verticalJump
    case dropJump
    case singleLegCMJ
    case repeatedJumps
    case balance

    /// The jump test this tool runs, or nil for balance.
    var jumpTest: JumpTestKind? {
        switch self {
        case .cmj: .cmj
        case .verticalJump: .verticalJump
        case .dropJump: .dropJump
        case .singleLegCMJ: .singleLegCMJ
        case .repeatedJumps: .repeatedJumps
        case .balance: nil
        }
    }

    var title: String { jumpTest?.title ?? "Balance" }

    var message: String { jumpTest?.summary ?? "Stand on one leg for 30 seconds. Sway, left against right." }

    /// The SF Symbol on the tool's tile.
    var systemImage: String {
        switch self {
        case .cmj: "bolt.fill"
        case .verticalJump: "arrow.up.to.line"
        case .dropJump: "arrow.down.to.line"
        case .singleLegCMJ: "figure.stand"
        case .repeatedJumps: "repeat"
        case .balance: "figure.mind.and.body"
        }
    }
}
