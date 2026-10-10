//
//  JumpTestKind.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// A jump test the engine can run. Each one is a **tag plan** (the events the
/// athlete marks on the replay, in order) and a number of attempts, and the
/// engine does the rest: record, tag, measure, best of the attempts.
///
/// Vertical Jump is the first. CMJ, drop jump, single-leg CMJ and repeated
/// jumps join it in later phases (`PERFORMANCE_PLAN.md`, part 2), each as a
/// new case here rather than a new screen. A drop jump, for instance, is
/// `[.landing, .takeOff, .landing]`: the contact off the box, the rebound,
/// and the landing after it.
///
/// `rawValue` is what is stored as `kind` on a session document, so **a case
/// is never renamed**. `@frozen` because PerformanceKit builds with library
/// evolution.
@frozen
public enum JumpTestKind: String, Sendable, CaseIterable {
    case verticalJump

    var title: String {
        switch self {
        case .verticalJump: "Vertical Jump"
        }
    }

    var tagPlan: [JumpEvent] {
        switch self {
        case .verticalJump: [.takeOff, .landing]
        }
    }

    /// A test is the best of this many attempts. One jump is too noisy to
    /// track.
    var attempts: Int { 3 }
}
