//
//  PreviewJumpTestSessionsLoader.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 12/10/2026.
//
import Foundation

/// Ten weeks of plausible jump testing, for SwiftUI previews and the locked screen's blurred
/// preview of the dashboard.
///
/// **Fixed numbers, not random ones.** The locked screen draws the real dashboard from this, and a
/// random draw would make the fatigue card land in a different zone each time the tab appeared. The
/// flights are chosen so the latest CMJ sits a little under the best of the eight weeks before it —
/// a "watch it" reading rather than a flawless one, which is what a real week looks like. Every
/// height goes through `JumpPhysics`, so nothing here is a number a recording could not produce.
public final class PreviewJumpTestSessionsLoader: JumpTestSessionsLoader, @unchecked Sendable {

    private let now: Date

    public init(now: Date = Date()) {
        self.now = now
    }

    public func loadSessions(_ kind: JumpTestKind) async throws -> [JumpTestSession] {
        switch kind {
        case .cmj:
            // Oldest first, one a week; the newest is just under the best before it.
            let flights = [0.540, 0.546, 0.551, 0.553, 0.558, 0.561, 0.559, 0.566, 0.570, 0.561]
            return sessions(kind, flights: flights, contact: nil)
        case .verticalJump:
            return sessions(kind, flights: [0.585, 0.592, 0.598, 0.601], contact: nil)
        case .dropJump:
            return sessions(kind, flights: [0.500, 0.508, 0.512], contact: 0.21)
        case .singleLegCMJ, .repeatedJumps:
            return []
        }
    }

    private func sessions(_ kind: JumpTestKind, flights: [Double], contact: Double?) -> [JumpTestSession] {
        flights.enumerated().map { index, flight in
            let weeksAgo = flights.count - 1 - index
            let date = Calendar.current.date(byAdding: .day, value: -7 * weeksAgo, to: now) ?? now
            let attempts = [flight, flight - 0.006, flight - 0.012].map { time in
                JumpAttempt(height: JumpPhysics.heightCentimetres(flightTime: time), flightTime: time, contactTime: contact)
            }
            return JumpTestSession(id: "preview-\(kind)-\(index)", kind: kind, date: date, attempts: attempts, bodyMass: 80)
        }
    }
}
