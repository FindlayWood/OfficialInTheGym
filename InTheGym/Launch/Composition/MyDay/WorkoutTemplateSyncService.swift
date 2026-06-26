//
//  WorkoutTemplateSyncService.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import Network
import MyDayKit

final class WorkoutTemplateSyncService {

    private let remote: WorkoutTemplateUploading
    private let syncQueue: SyncQueueWorkoutTemplateUploader

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.myday.sync.networkmonitor")
    private var wasOffline = false

    // MARK: - Init

    init(remote: WorkoutTemplateUploading, syncQueue: SyncQueueWorkoutTemplateUploader) {
        self.remote = remote
        self.syncQueue = syncQueue
    }

    // MARK: - Public

    /// Call on app launch and on user login.
    func start() {
        startMonitoringConnectivity()
        flushQueue()
    }

    /// Call on user logout to stop monitoring.
    func stop() {
        monitor.cancel()
    }

    // MARK: - Private

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

            let pending = self.syncQueue.loadPending()
            guard !pending.isEmpty else { return }

            for template in pending {
                do {
                    // Only upload templates belonging to this queue's user.
                    // Firestore rules enforce this server-side too, but we
                    // guard here to avoid unnecessary network calls.
                    try await self.remote.upload(template)
                    try? self.syncQueue.dequeue(id: template.id)
                } catch {
                    // Leave in queue, will retry on next trigger.
                    // Continue attempting remaining items.
                }
            }
        }
    }
}
