//
//  LimbSymmetry.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// How far apart the two legs are on a single-leg test: the gap as a share of
/// the stronger leg, and which leg is weaker.
///
/// **Asymmetry of 10% or more is notable** (`notableFrom`), the common line in
/// return-to-play testing below which a difference is treated as normal. The
/// one place that line is written down.
struct LimbSymmetry: Equatable {

    static let notableFrom = 0.10

    let left: Double
    let right: Double

    init?(left: Double, right: Double) {
        guard left > 0, right > 0 else { return nil }
        self.left = left
        self.right = right
    }

    /// The gap as a fraction of the stronger leg: 0 is perfectly even.
    var asymmetry: Double {
        abs(left - right) / max(left, right)
    }

    /// Nil when the legs are equal.
    var weaker: JumpSide? {
        left == right ? nil : (left < right ? .left : .right)
    }

    var isNotable: Bool {
        asymmetry >= Self.notableFrom
    }

    /// "Right leg 8% weaker", or "Even".
    var summary: String {
        guard let weaker else { return "Even" }
        let percent = Int((asymmetry * 100).rounded())
        return percent == 0 ? "Even" : "\(weaker.title) leg \(percent)% weaker"
    }
}
