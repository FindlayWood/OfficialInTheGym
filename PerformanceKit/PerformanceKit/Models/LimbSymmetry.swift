//
//  LimbSymmetry.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// How far apart the two legs are on a single-leg test: the gap as a share of
/// the larger figure, and which leg is weaker.
///
/// `higherIsBetter` is true for jump height and false for balance sway, where
/// the leg that sways more is the weaker one. The gap is always over the larger
/// figure, so the percentage means the same thing for both.
///
/// **Asymmetry of 10% or more is notable** (`notableFrom`), the common line in
/// return-to-play testing below which a difference is treated as normal. The
/// one place that line is written down.
struct LimbSymmetry: Equatable {

    static let notableFrom = 0.10

    let left: Double
    let right: Double
    let higherIsBetter: Bool

    init?(left: Double, right: Double, higherIsBetter: Bool = true) {
        guard left > 0, right > 0 else { return nil }
        self.left = left
        self.right = right
        self.higherIsBetter = higherIsBetter
    }

    /// The gap as a fraction of the larger figure: 0 is perfectly even.
    var asymmetry: Double {
        abs(left - right) / max(left, right)
    }

    /// Nil when the legs are equal.
    var weaker: JumpSide? {
        guard left != right else { return nil }
        let leftIsLower = left < right
        return leftIsLower == higherIsBetter ? .left : .right
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
