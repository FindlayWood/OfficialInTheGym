//
//  BalanceSession.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// One sitting of the balance test: up to `attemptsPerSide` stands on each
/// leg under one condition. Its result is each leg's best (lowest sway among
/// complete stands) and the asymmetry between them.
public struct BalanceSession: Equatable, Sendable, Identifiable {
    public let id: String
    public let date: Date
    public let condition: BalanceCondition
    public let attempts: [BalanceAttempt]

    static let attemptsPerSide = 2

    public init(id: String, date: Date, condition: BalanceCondition, attempts: [BalanceAttempt]) {
        self.id = id
        self.date = date
        self.condition = condition
        self.attempts = attempts
    }

    /// The steadiest complete stand on one leg. Incomplete stands never count.
    func best(on side: JumpSide) -> BalanceAttempt? {
        attempts.filter { $0.side == side && $0.completed }.min { $0.sway < $1.sway }
    }

    /// Left against right, lower sway better.
    var symmetry: LimbSymmetry? {
        guard let left = best(on: .left)?.sway, let right = best(on: .right)?.sway else { return nil }
        return LimbSymmetry(left: left, right: right, higherIsBetter: false)
    }
}
