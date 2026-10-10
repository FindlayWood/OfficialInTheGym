//
//  JumpEvent.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// A moment the athlete tags on the replay: the last frame with the feet on
/// the ground (`takeOff`) or the first frame they are back on it (`landing`).
/// Every jump test is a sequence of these (`JumpTestKind.tagPlan`); what each
/// one is called and how to spot it is the test's (`tagTitles`, `tagHints`),
/// since a drop jump's first landing and its last are different moments.
public enum JumpEvent: String, Sendable, CaseIterable {
    case takeOff
    case landing

    /// The marker drawn on the scrubber where this event was tagged.
    var markerSymbol: String {
        switch self {
        case .takeOff: "arrow.up"
        case .landing: "arrow.down"
        }
    }
}
