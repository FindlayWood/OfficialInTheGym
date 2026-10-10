//
//  JumpEvent.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// A moment the athlete tags on the replay: the last frame with the feet on
/// the ground (`takeOff`) or the first frame they are back on it (`landing`).
/// Every jump test is a sequence of these (`JumpTestKind.tagPlan`).
public enum JumpEvent: String, Sendable, CaseIterable {
    case takeOff
    case landing

    var title: String {
        switch self {
        case .takeOff: "take-off"
        case .landing: "landing"
        }
    }

    /// What to look for when tagging it, shown above the tag button.
    var hint: String {
        switch self {
        case .takeOff: "Step to the last frame your feet are on the ground."
        case .landing: "Step to the first frame your feet are back on the ground."
        }
    }

    /// The marker drawn on the scrubber where this event was tagged.
    var markerSymbol: String {
        switch self {
        case .takeOff: "arrow.up"
        case .landing: "arrow.down"
        }
    }
}
