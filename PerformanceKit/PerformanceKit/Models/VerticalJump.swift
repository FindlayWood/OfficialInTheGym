//
//  VerticalJump.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// One measured jump: when, and how high in centimetres. Heights are always
/// stored in centimetres. Inches are a display choice (`JumpMeasurement`).
public struct VerticalJump: Equatable, Sendable {
    public let time: Date
    public let height: Double

    public init(time: Date, height: Double) {
        self.time = time
        self.height = height
    }

    /// The athlete's best jump once `new` is counted: `new` if it is higher than
    /// the current best, which it always is when there is no best yet.
    ///
    /// **A jump that only equals the best does not replace it**, so the best
    /// keeps the date it was first reached. This is the legacy rule from
    /// `JumpResultsViewModel.saveResult()`, now on its own so it can be tested.
    static func best(current: VerticalJump?, new: VerticalJump) -> VerticalJump {
        guard let current else { return new }
        return new.height > current.height ? new : current
    }
}
