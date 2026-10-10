//
//  JumpTestSession.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// One sitting of a jump test: its attempts, and the best of them, which is
/// the session's result. The best is the attempt with the highest score for
/// the test (`JumpAttempt.score(for:)`): height, or RSI for a drop jump, where
/// the highest jump off a long ground contact is not the best one. It is
/// worked out here, never stored separately and allowed to disagree.
///
/// `boxHeight` is the box a drop jump was done off, in centimetres; RSI is only
/// comparable between sessions off the same box.
///
/// **`bodyMass` is the athlete's weight when the test was done**, stored with
/// it so the session's power does not change when their weight does. Nil when
/// none was logged, and for sessions saved before power existed.
///
/// The athlete's best ever is the best of their sessions (`best(of:)`). The
/// legacy app kept a separate best-jump document, which a failed second write
/// could leave out of step with the history it summarised.
public struct JumpTestSession: Equatable, Sendable, Identifiable {
    public let id: String
    public let kind: JumpTestKind
    public let date: Date
    public let attempts: [JumpAttempt]
    public let bodyMass: Double?
    public let boxHeight: Double?

    public init(id: String, kind: JumpTestKind, date: Date, attempts: [JumpAttempt], bodyMass: Double? = nil, boxHeight: Double? = nil) {
        self.id = id
        self.kind = kind
        self.date = date
        self.attempts = attempts
        self.bodyMass = bodyMass
        self.boxHeight = boxHeight
    }

    public var best: JumpAttempt? {
        attempts.max { $0.score(for: kind) < $1.score(for: kind) }
    }

    /// The session's score, what ranks it against other sessions: the best
    /// attempt's height or RSI. **For a single-leg test it is the weaker leg's
    /// best**, so a session improves when the weak leg does, not when the
    /// strong one does more; nil until both legs have a jump.
    var bestScore: Double? {
        guard !kind.sides.isEmpty else { return best?.score(for: kind) }
        let sideBests = kind.sides.map { best(on: $0)?.score(for: kind) }
        guard sideBests.allSatisfy({ $0 != nil }) else { return nil }
        return sideBests.compactMap { $0 }.min()
    }

    /// The best attempt on one leg.
    func best(on side: JumpSide) -> JumpAttempt? {
        attempts.filter { $0.side == side }.max { $0.score(for: kind) < $1.score(for: kind) }
    }

    /// Left against right, for a single-leg session with a jump on each.
    var symmetry: LimbSymmetry? {
        guard kind.sides == [.left, .right],
              let left = best(on: .left)?.height,
              let right = best(on: .right)?.height else { return nil }
        return LimbSymmetry(left: left, right: right)
    }

    /// The best attempt's power, for a test that estimates it and a session
    /// with a body mass.
    var power: JumpPower? {
        guard kind.estimatesPower, let height = best?.height, let bodyMass else { return nil }
        return JumpPower(heightCentimetres: height, bodyMassKilograms: bodyMass)
    }

    /// The session with the highest best score. Ties go to the earlier
    /// session, so a best keeps the date it was first reached.
    static func best(of sessions: [JumpTestSession]) -> JumpTestSession? {
        sessions
            .filter { $0.bestScore != nil }
            .sorted { $0.date < $1.date }
            .reduce(nil) { current, next in
                guard let current, let currentBest = current.bestScore else { return next }
                return (next.bestScore ?? 0) > currentBest ? next : current
            }
    }
}
