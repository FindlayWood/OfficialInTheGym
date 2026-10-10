//
//  FatigueCheck.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The weekly fatigue check: the latest CMJ session's best, as a fraction of
/// the best CMJ in the eight weeks before it.
///
/// - **Every CMJ session is a check.** The check is three CMJs, which is
///   exactly a CMJ session, so it is not a second kind of record. A CMJ done
///   any other day counts too, and the next check is due a week after it.
/// - **The max is recent, not all-time.** An all-time max is set once and only
///   rises: one outlier day, or a peak from earlier in the season, would make
///   every later check read as fatigued. The best of the **eight weeks before
///   the latest session** keeps the "% of max" framing without an old PB
///   setting the bar for good.
/// - **The window is anchored to the latest session, not to today**, so a
///   result does not change as the days pass without a new test.
/// - **Calibrating until there are two earlier sessions in the window.** One
///   earlier jump is too thin a max to judge against; until then the check says
///   so rather than giving a false result.
/// - A latest best above the max reads over 100%, fresh, and a new best.
struct FatigueCheck: Equatable {

    static let windowDays = 56
    static let earlierSessionsNeeded = 2
    static let dueAfterDays = 7

    enum Status: Equatable {
        /// No CMJ yet.
        case none
        /// Not enough history to judge. `sessions` counts the latest too.
        case calibrating(sessions: Int, needed: Int)
        case result(fraction: Double, zone: FatigueZone, reference: JumpTestSession)
    }

    let status: Status
    let latest: JumpTestSession?
    let nextDue: Date?

    init(sessions: [JumpTestSession], calendar: Calendar = .current) {
        let cmj = sessions.filter { $0.kind == .cmj && $0.best != nil }
        guard let latest = cmj.max(by: { $0.date < $1.date }), let latestHeight = latest.best?.height else {
            self.status = .none
            self.latest = nil
            self.nextDue = nil
            return
        }
        self.latest = latest
        self.nextDue = calendar.date(byAdding: .day, value: Self.dueAfterDays, to: latest.date)

        let windowStart = calendar.date(byAdding: .day, value: -Self.windowDays, to: latest.date) ?? latest.date
        let earlier = cmj.filter { $0.id != latest.id && $0.date < latest.date && $0.date >= windowStart }
        guard earlier.count >= Self.earlierSessionsNeeded, let reference = JumpTestSession.best(of: earlier),
              let referenceHeight = reference.best?.height, referenceHeight > 0 else {
            self.status = .calibrating(sessions: earlier.count + 1, needed: Self.earlierSessionsNeeded + 1)
            return
        }
        let fraction = latestHeight / referenceHeight
        self.status = .result(fraction: fraction, zone: FatigueZone(fraction: fraction), reference: reference)
    }

    /// Whether this week's check is due: no CMJ yet, or a week since the last.
    func isDue(now: Date) -> Bool {
        guard let nextDue else { return true }
        return now >= nextDue
    }

    /// A latest best above the recent max.
    var isNewBest: Bool {
        if case .result(let fraction, _, _) = status { return fraction > 1 }
        return false
    }
}
