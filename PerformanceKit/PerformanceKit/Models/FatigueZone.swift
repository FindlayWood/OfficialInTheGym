//
//  FatigueZone.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// What a weekly check's percentage means. **The only place the boundaries are
/// written down**: 95% and above is fresh, 90% up to 95% caution, below 90%
/// fatigued, of the athlete's recent best. A 5–10% drop in CMJ height is about
/// where a change stops being day-to-day noise. It owns the colours too, the
/// same split `ACWR.Zone` makes in StatsKit.
///
/// The thresholds are fixed for now. Letting an athlete, or later a coach, set
/// them is an open question in `PERFORMANCE_PLAN.md`.
enum FatigueZone: Equatable, CaseIterable {
    case fresh
    case caution
    case fatigued

    static let freshFrom = 0.95
    static let cautionFrom = 0.90

    init(fraction: Double) {
        if fraction >= Self.freshFrom {
            self = .fresh
        } else if fraction >= Self.cautionFrom {
            self = .caution
        } else {
            self = .fatigued
        }
    }

    var title: String {
        switch self {
        case .fresh: "Fresh"
        case .caution: "Caution"
        case .fatigued: "Fatigued"
        }
    }

    var advice: String {
        switch self {
        case .fresh: "You're jumping at your usual level."
        case .caution: "A little down on your usual. Worth keeping an eye on."
        case .fatigued: "Well down on your usual. Consider an easier day."
        }
    }

    var color: Color {
        switch self {
        case .fresh: .matteGreen
        case .caution: .matteAmber
        case .fatigued: .matteRed
        }
    }
}
