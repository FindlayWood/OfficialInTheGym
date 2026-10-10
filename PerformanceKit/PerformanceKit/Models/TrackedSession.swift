//
//  TrackedSession.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// A recorded match or practice: the athlete's own ratings (0–10) and notes,
/// and a snapshot of their training state when they recorded it. The snapshot
/// is taken once and never refreshed. It says what the numbers were then.
public struct TrackedSession: Equatable, Sendable {
    /// The Realtime Database key, minted when the session is written.
    public let id: String
    public let date: Date
    public let ratings: TrackedSessionRatings
    public let notes: String
    public let workloadRatio: WorkloadRatio?
    public let mostRecentWorkload: Workload?
    public let wellness: WellnessSnapshot?
    public let cmj: CMJSnapshot?

    public init(
        id: String,
        date: Date,
        ratings: TrackedSessionRatings,
        notes: String,
        workloadRatio: WorkloadRatio?,
        mostRecentWorkload: Workload?,
        wellness: WellnessSnapshot?,
        cmj: CMJSnapshot?
    ) {
        self.id = id
        self.date = date
        self.ratings = ratings
        self.notes = notes
        self.workloadRatio = workloadRatio
        self.mostRecentWorkload = mostRecentWorkload
        self.wellness = wellness
        self.cmj = cmj
    }
}
