//
//  JumpTestKind.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// A jump test the engine can run. Each one is a **tag plan** (the events the
/// athlete marks on the replay, in order) and a number of attempts, and the
/// engine does the rest: record, tag, measure, best of the attempts. The
/// screens are shared too (`JumpTestHomeScreen`, `JumpTestHistoryScreen`), so a
/// new jump test is a new case here, not new screens.
///
/// - **CMJ** (countermovement jump): hands on hips, no arm swing. The
///   repeatable test, the one the weekly fatigue check uses, and the one
///   power is estimated from.
/// - **Vertical Jump**: arm swing allowed. The "how high can I go" number.
///
/// Drop jump, single-leg CMJ and repeated jumps join in later phases
/// (`PERFORMANCE_PLAN.md`, part 2). A drop jump, for instance, is
/// `[.landing, .takeOff, .landing]`.
///
/// `rawValue` is what is stored as `kind` on a session document, so **a case
/// is never renamed**. `@frozen` because PerformanceKit builds with library
/// evolution.
@frozen
public enum JumpTestKind: String, Sendable, CaseIterable {
    case cmj
    case verticalJump

    var title: String {
        switch self {
        case .cmj: "CMJ"
        case .verticalJump: "Vertical Jump"
        }
    }

    /// One line on what the test is, under its title.
    var summary: String {
        switch self {
        case .cmj: "Countermovement jump, hands on hips. Height and power."
        case .verticalJump: "Jump height with arm swing, measured on camera."
        }
    }

    var tagPlan: [JumpEvent] {
        switch self {
        case .cmj, .verticalJump: [.takeOff, .landing]
        }
    }

    /// A test is the best of this many attempts. One jump is too noisy to
    /// track.
    var attempts: Int { 3 }

    /// Whether peak power is estimated from this test's height. Only CMJ: the
    /// estimate (`JumpPower`) was fitted to jumps without arm swing, and an arm
    /// swing adds height the legs did not produce.
    var estimatesPower: Bool {
        self == .cmj
    }

    /// How to do one jump, the step the instructions add to the shared ones.
    var technique: String {
        switch self {
        case .cmj: "Stand tall with your hands on your hips. Dip and jump straight up as high as you can, keeping your hands on your hips and your legs straight in the air."
        case .verticalJump: "Stand tall, swing your arms, and jump straight up as high as you can. Land on the spot."
        }
    }
}
