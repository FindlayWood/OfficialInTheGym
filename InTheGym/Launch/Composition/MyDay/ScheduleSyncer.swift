//
//  ScheduleSyncer.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Tries the remote write and, if it fails, queues the schedule for
/// `ScheduleSyncService` to retry, `CustomExerciseSyncer`'s shape.
final class ScheduleSyncer: ScheduleUploading {

    private let remote: ScheduleUploading
    private let queue: ScheduleUploading

    init(remote: ScheduleUploading, queue: ScheduleUploading) {
        self.remote = remote
        self.queue = queue
    }

    func upload(_ schedule: Schedule) async throws {
        do {
            try await remote.upload(schedule)
        } catch {
            try await queue.upload(schedule)
        }
    }
}
