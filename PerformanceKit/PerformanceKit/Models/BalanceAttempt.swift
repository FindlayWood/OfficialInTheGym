//
//  BalanceAttempt.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// One single-leg stand: how much the athlete swayed (`sway`, thousandths of a
/// g, lower is steadier) and how long they held it (`duration`, seconds).
///
/// **An attempt is complete only if it lasted the full stand** (`completed`).
/// One stopped early with "Foot down" is kept, so the athlete sees it, but
/// never counts toward a best: a short stand sways less simply by being short.
public struct BalanceAttempt: Equatable, Sendable {
    public let sway: Double
    public let duration: Double
    public let side: JumpSide

    /// The length of a full stand, in seconds.
    static let targetDuration: Double = 30

    public init(sway: Double, duration: Double, side: JumpSide) {
        self.sway = sway
        self.duration = duration
        self.side = side
    }

    /// Within half a second of the full stand, so timer granularity never
    /// turns a full stand into an incomplete one.
    var completed: Bool {
        duration >= Self.targetDuration - 0.5
    }

    func on(_ side: JumpSide) -> BalanceAttempt {
        BalanceAttempt(sway: sway, duration: duration, side: side)
    }
}
