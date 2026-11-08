//
//  ScheduleSaver.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// The writer MyDayKit is handed: local first, then remote in the background,
/// `CustomExerciseSaver`'s shape.
///
/// **Only the local write can fail the save.** Once the file is on disk the
/// schedule exists and shows on MyDay; the remote copy is the syncer's problem,
/// which queues rather than loses it.
final class ScheduleSaver: ScheduleUploading {

    private let local: ScheduleUploading
    private let remote: ScheduleUploading

    init(local: ScheduleUploading, remote: ScheduleUploading) {
        self.local = local
        self.remote = remote
    }

    func upload(_ schedule: Schedule) async throws {
        try await local.upload(schedule)

        Task.detached(priority: .background) { [remote] in
            try? await remote.upload(schedule)
        }
    }
}
