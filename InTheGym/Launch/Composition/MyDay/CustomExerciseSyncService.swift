//
//  CustomExerciseSyncService.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit
import Network

/// Flushes the custom exercise sync queue on start and whenever the network
/// comes back — `WorkoutTemplateSyncService`'s shape, for the same reason: a
/// write made offline must reach both copies without the user doing anything.
///
/// `MyDayKitComposition` holds it for the signed-in session and stops it on
/// sign-out, as it does the template service.
final class CustomExerciseSyncService {

    private let remote: CustomExerciseUploading
    private let syncQueue: SyncQueueCustomExerciseUploader

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.myday.sync.customexercises")
    private var wasOffline = false

    // MARK: - Init

    init(remote: CustomExerciseUploading, syncQueue: SyncQueueCustomExerciseUploader) {
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

            for exercise in self.syncQueue.loadPending() {
                do {
                    try await self.remote.upload(exercise)
                    try? self.syncQueue.dequeue(exercise)
                } catch {
                    // Left in the queue for the next flush.
                }
            }
        }
    }
}
