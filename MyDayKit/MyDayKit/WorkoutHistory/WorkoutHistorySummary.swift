//
//  WorkoutHistorySummary.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation

/// What the user's finished sessions of one workout add up to: how often, how recently, how long
/// and how hard.
///
/// **Each average is over the sessions that carry that value, never padded with zeros.** A session
/// finished before RPE was required, or one with no end time, has nothing to say about that
/// measure, and counting it as 0 would drag the average down for a reason that is not training.
/// An average with nothing behind it is `nil`, drawn as "—", not 0.
///
/// A session marked `deletedAt` is left out. Only the analytics copy is ever marked, so this should
/// never see one, but a deleted session counting toward "times done" would be a claim of work the
/// user retracted.
public struct WorkoutHistorySummary: Equatable, Sendable {

    public let timesDone: Int
    /// When the latest session ended, or started if it has no end.
    public let lastDone: Date?
    public let averageDurationSeconds: Int?
    public let averageRPE: Double?

    public init(sessions: [CompletedWorkoutSession]) {
        let counted = sessions.filter { $0.deletedAt == nil }
        timesDone = counted.count
        lastDone = counted.map { $0.endedAt ?? $0.startedAt }.max()

        let durations = counted.compactMap(Self.durationSeconds(of:))
        averageDurationSeconds = durations.isEmpty
            ? nil
            : Int((Double(durations.reduce(0, +)) / Double(durations.count)).rounded())

        let rpes = counted.compactMap(\.rpe)
        averageRPE = rpes.isEmpty ? nil : Double(rpes.reduce(0, +)) / Double(rpes.count)
    }

    /// The stored duration, else the gap between start and end. A session with neither, or one
    /// whose clock ran backwards, has no duration rather than a zero one.
    static func durationSeconds(of session: CompletedWorkoutSession) -> Int? {
        if let stored = session.durationSeconds, stored > 0 { return stored }
        guard let endedAt = session.endedAt else { return nil }
        let seconds = Int(endedAt.timeIntervalSince(session.startedAt))
        return seconds > 0 ? seconds : nil
    }
}
