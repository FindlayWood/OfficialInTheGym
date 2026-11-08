//
//  ScheduleSyncService.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import MyDayKit
import Network

/// Flushes the schedule sync queue on start and whenever the network comes back,
/// `CustomExerciseSyncService`'s shape, for the same reason: a write made offline
/// must reach Firestore without the user doing anything.
///
/// `MyDayKitComposition` holds it for the signed-in session and stops it on
/// sign-out. **Never build it as a local**: its flush and monitor hold it weakly,
/// so it would be gone once launch finished and nothing queued would be retried.
final class ScheduleSyncService {

    private let remote: ScheduleUploading
    private let syncQueue: SyncQueueScheduleUploader

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.myday.sync.schedules")
    private var wasOffline = false

    // MARK: - Init

    init(remote: ScheduleUploading, syncQueue: SyncQueueScheduleUploader) {
        self.remote = remote
        self.syncQueue = syncQueue
    }

    deinit {
        monitor.cancel()
    }

    // MARK: - Public

    func start() {
        startMonitoringConnectivity()
        flushQueue()
    }

    func stop() {
        monitor.cancel()
    }

    // MARK: - Private

    /// Permission denied is the one failure retrying cannot fix: the SDK never
    /// retries it either.
    private static func isRefusedByRules(_ error: Error) -> Bool {
        let error = error as NSError
        return error.domain == FirestoreErrorDomain
            && error.code == FirestoreErrorCode.permissionDenied.rawValue
    }

    private func startMonitoringConnectivity() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            if path.status == .satisfied && self.wasOffline {
                self.wasOffline = false
                self.flushQueue()
            } else if path.status != .satisfied {
                self.wasOffline = true
            }
        }
        monitor.start(queue: monitorQueue)
    }

    private func flushQueue() {
        Task.detached(priority: .background) { [weak self] in
            guard let self else { return }

            for schedule in self.syncQueue.loadPending() {
                do {
                    try await self.remote.upload(schedule)
                    try? self.syncQueue.dequeue(schedule)
                } catch where Self.isRefusedByRules(error) {
                    // The rules will refuse it every time. The local copy keeps
                    // the schedule, so MyDay still shows it on this device.
                    print("❌ Dropping schedule \(schedule.id) the rules refuse: \(error)")
                    try? self.syncQueue.dequeue(schedule)
                } catch {
                    // Anything else is worth retrying: left for the next flush.
                }
            }
        }
    }
}
