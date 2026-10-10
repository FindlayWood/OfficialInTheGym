//
//  Workload.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// One entry in the athlete's workload log, the legacy `WorkloadModel` read
/// out of the Realtime Database. Each source of load has its own field:
/// `workload` from the legacy workout flow, `customAddedWorkload` added by
/// hand, `matchWorkload` and `practiceWorkload` from the trackers.
///
/// **This log is not MyDay's.** Nothing MyDay records reaches it; StatsKit reads
/// MyDay's `DailyTotal`s instead. See `PERFORMANCE_PLAN.md`.
public struct Workload: Equatable, Sendable {
    /// The Realtime Database key. Ignored by `WorkloadWriter`, which mints one.
    public let id: String
    public let endTime: Date
    public let rpe: Int
    /// Seconds.
    public let timeToComplete: Int
    public let workload: Int
    public let customAddedWorkload: Int?
    public let matchWorkload: Int?
    public let practiceWorkload: Int?
    /// The tracked session that logged this load, for a match or practice.
    public let workoutID: String?

    public init(
        id: String,
        endTime: Date,
        rpe: Int,
        timeToComplete: Int,
        workload: Int,
        customAddedWorkload: Int? = nil,
        matchWorkload: Int? = nil,
        practiceWorkload: Int? = nil,
        workoutID: String? = nil
    ) {
        self.id = id
        self.endTime = endTime
        self.rpe = rpe
        self.timeToComplete = timeToComplete
        self.workload = workload
        self.customAddedWorkload = customAddedWorkload
        self.matchWorkload = matchWorkload
        self.practiceWorkload = practiceWorkload
        self.workoutID = workoutID
    }

    /// Every source added together, as the ratio counts it.
    var total: Double {
        Double(workload)
            + Double(customAddedWorkload ?? 0)
            + Double(matchWorkload ?? 0)
            + Double(practiceWorkload ?? 0)
    }
}
