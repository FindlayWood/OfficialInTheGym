//
//  JumpTestSession.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// One sitting of a jump test: its attempts, and the best of them, which is
/// the session's result. The best is the highest attempt. It is worked out
/// here, never stored separately and allowed to disagree.
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

    public init(id: String, kind: JumpTestKind, date: Date, attempts: [JumpAttempt], bodyMass: Double? = nil) {
        self.id = id
        self.kind = kind
        self.date = date
        self.attempts = attempts
        self.bodyMass = bodyMass
    }

    public var best: JumpAttempt? {
        attempts.max { $0.height < $1.height }
    }

    /// The best attempt's power, for a test that estimates it and a session
    /// with a body mass.
    var power: JumpPower? {
        guard kind.estimatesPower, let height = best?.height, let bodyMass else { return nil }
        return JumpPower(heightCentimetres: height, bodyMassKilograms: bodyMass)
    }

    /// The session with the highest best. Ties go to the earlier session, so a
    /// best keeps the date it was first reached.
    static func best(of sessions: [JumpTestSession]) -> JumpTestSession? {
        sessions
            .filter { $0.best != nil }
            .sorted { $0.date < $1.date }
            .reduce(nil) { current, next in
                guard let current, let currentBest = current.best?.height else { return next }
                return (next.best?.height ?? 0) > currentBest ? next : current
            }
    }
}
