//
//  StatsInjuryImpact.swift
//  StatsKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// How much an injury changed training that day. **StatsKit's copy of MyDayKit's
/// `InjuryImpact`** — StatsKit imports no other framework — so the cases must stay in step,
/// raw values included, since the composition root maps one onto the other by raw value.
public enum StatsInjuryImpact: String, CaseIterable, Hashable, Sendable {
    case none
    case modified
    case stopped

    var title: String {
        switch self {
        case .none: return "As normal"
        case .modified: return "Around it"
        case .stopped: return "Not training"
        }
    }
}
