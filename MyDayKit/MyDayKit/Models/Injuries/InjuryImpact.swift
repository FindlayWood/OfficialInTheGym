//
//  InjuryImpact.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// How much an injury is changing training today — the answer to "is it still affecting me".
///
/// **Three steps, not a yes / no.** Most days with a niggle are neither "fine" nor "stopped":
/// training goes ahead with something changed, and a yes / no would make the user pick a lie.
/// The middle step is the common one.
///
/// **The raw value is stored.** Add cases; never rename one.
public enum InjuryImpact: String, CaseIterable, Codable, Hashable, Sendable {
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

    /// For a summary line: "Pain 3 · Training around it".
    var summary: String {
        switch self {
        case .none: return "Training as normal"
        case .modified: return "Training around it"
        case .stopped: return "Not training"
        }
    }
}
