//
//  PerformanceTool.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The tools Performance Center lists, in the order it lists them. This was
/// the app target's `PerformanceIntroOptions`, carried across with its copy
/// unchanged.
///
/// Wellness, Training Status, CMJ and Injury Tracker were already commented out
/// of that enum and are not cases here. Their code stays in the app target,
/// untouched, until someone decides whether they come back.
///
/// `@frozen` because PerformanceKit builds with library evolution. Without it,
/// every `switch` over a tool in the app needs an `@unknown default`.
@frozen
public enum PerformanceTool: CaseIterable, Sendable {
    case matchTracker
    case practiceTracker
    case workload
    case verticalJump
    case journal

    var title: String {
        switch self {
        case .matchTracker: "Match Tracker"
        case .practiceTracker: "Practice Tracker"
        case .workload: "Workload"
        case .verticalJump: "Vertical Jump"
        case .journal: "Journal"
        }
    }

    var message: String {
        switch self {
        case .matchTracker: "Track and record all matches/games/competitions."
        case .practiceTracker: "Track and record all practice sessions."
        case .workload: "Monitor your workload."
        case .verticalJump: "Measure your vertical jump."
        case .journal: "Keep a private journal of your every day."
        }
    }

    /// An image in PerformanceKit's own asset catalog. Copies of the app's
    /// icons, because a framework cannot read the app's catalog.
    var imageName: String {
        switch self {
        case .matchTracker: "contest_icon"
        case .practiceTracker: "circuit_icon"
        case .workload: "bar-chart_icon"
        case .verticalJump: "jump_icon"
        case .journal: "journal_icon"
        }
    }

    /// **The journal is never shown to anyone but its author.** A coach opening
    /// an athlete's Performance Center sees every other tool. The legacy screen
    /// applied the same rule.
    var isOwnerOnly: Bool {
        self == .journal
    }
}
