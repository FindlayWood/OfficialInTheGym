//
//  NewTrackedSessionViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// Recording a match or practice.
///
/// Saving takes a snapshot of the athlete's training state (the workload
/// ratio over their workload log, their latest workload, wellness and CMJ),
/// stores it with the ratings, then adds the session's own load to the
/// workload log, linked by the id the session was stored under. **The order is
/// the legacy one and it matters**: the snapshot is taken before the session's
/// own load is added, so it describes the athlete coming into the session.
///
/// Fixed in the move:
/// - **A failed save puts the button back.** The legacy view models left the
///   spinner up when the workload log could not be read (match and practice)
///   or when the write failed (practice), with no way to try again.
/// - A failure after the session is stored but before its load is logged
///   leaves the session without its workload entry, as the legacy code did.
///   Saving again records the session a second time.
@MainActor
final class NewTrackedSessionViewModel: ObservableObject {

    let kind: TrackedSessionKind

    @Published var ratings = TrackedSessionRatings()
    @Published var note = ""
    @Published var rpe = 5
    /// Minutes, 0–240.
    @Published var duration: Double = 60
    @Published private(set) var isUploading = false

    private let workloadsLoader: WorkloadsLoader
    private let wellnessLoader: WellnessSnapshotLoader
    private let cmjLoader: CMJSnapshotLoader
    private let sessionWriter: TrackedSessionWriter
    private let workloadWriter: WorkloadWriter
    private let now: () -> Date
    private let calendar: Calendar

    init(
        kind: TrackedSessionKind,
        workloadsLoader: WorkloadsLoader,
        wellnessLoader: WellnessSnapshotLoader,
        cmjLoader: CMJSnapshotLoader,
        sessionWriter: TrackedSessionWriter,
        workloadWriter: WorkloadWriter,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current
    ) {
        self.kind = kind
        self.workloadsLoader = workloadsLoader
        self.wellnessLoader = wellnessLoader
        self.cmjLoader = cmjLoader
        self.sessionWriter = sessionWriter
        self.workloadWriter = workloadWriter
        self.now = now
        self.calendar = calendar
    }

    func save() async throws -> TrackedSession {
        isUploading = true
        defer { isUploading = false }

        let date = now()
        let workloads = try await workloadsLoader.loadWorkloads()
        let ratio = WorkloadRatio.calculate(from: workloads) { [calendar] in
            WorkloadRatio.daysAgo($0, now: date, calendar: calendar)
        }
        let cmj = await cmjLoader.loadCMJ()
        let wellness = await wellnessLoader.loadWellness()

        let session = TrackedSession(
            id: "",
            date: date,
            ratings: ratings,
            notes: note,
            workloadRatio: ratio,
            mostRecentWorkload: workloads.max { $0.endTime < $1.endTime },
            wellness: wellness,
            cmj: cmj
        )
        let stored = try await sessionWriter.write(session, kind: kind)
        try await workloadWriter.write(kind.workload(sessionId: stored.id, endTime: date, rpe: rpe, durationMinutes: duration))
        return stored
    }
}
