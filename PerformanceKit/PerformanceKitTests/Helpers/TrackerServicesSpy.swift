//
//  TrackerServicesSpy.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation
@testable import PerformanceKit

/// Records every call the trackers make, in order, which is what the save
/// sequence is tested against. Results are settable. Never asserts — the
/// test does.
final class TrackerServicesSpy: TrackedSessionsLoader, TrackedSessionWriter, WorkloadsLoader, WorkloadWriter, WellnessSnapshotLoader, CMJSnapshotLoader, @unchecked Sendable {

    enum Message: Equatable {
        case loadSessions(TrackedSessionKind)
        case writeSession(TrackedSession, TrackedSessionKind)
        case loadWorkloads
        case writeWorkload(Workload)
        case loadWellness
        case loadCMJ
    }

    private(set) var receivedMessages: [Message] = []
    var sessionsResult: Result<[TrackedSession], Error> = .success([])
    var workloadsResult: Result<[Workload], Error> = .success([])
    var storedSessionId = "stored-id"
    var writeSessionError: Error?
    var writeWorkloadError: Error?
    var wellness: WellnessSnapshot?
    var cmj: CMJSnapshot?

    func loadSessions(_ kind: TrackedSessionKind) async throws -> [TrackedSession] {
        receivedMessages.append(.loadSessions(kind))
        return try sessionsResult.get()
    }

    func write(_ session: TrackedSession, kind: TrackedSessionKind) async throws -> TrackedSession {
        receivedMessages.append(.writeSession(session, kind))
        if let writeSessionError { throw writeSessionError }
        return TrackedSession(
            id: storedSessionId, date: session.date, ratings: session.ratings, notes: session.notes,
            workloadRatio: session.workloadRatio, mostRecentWorkload: session.mostRecentWorkload,
            wellness: session.wellness, cmj: session.cmj
        )
    }

    func loadWorkloads() async throws -> [Workload] {
        receivedMessages.append(.loadWorkloads)
        return try workloadsResult.get()
    }

    func write(_ workload: Workload) async throws {
        receivedMessages.append(.writeWorkload(workload))
        if let writeWorkloadError { throw writeWorkloadError }
    }

    func loadWellness() async -> WellnessSnapshot? {
        receivedMessages.append(.loadWellness)
        return wellness
    }

    func loadCMJ() async -> CMJSnapshot? {
        receivedMessages.append(.loadCMJ)
        return cmj
    }
}
