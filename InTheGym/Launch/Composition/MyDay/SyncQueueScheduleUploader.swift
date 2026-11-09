//
//  SyncQueueScheduleUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Holds schedules whose remote write failed, at
/// `Documents/PendingSync/schedules_{userId}.json`, until `ScheduleSyncService`
/// flushes them.
///
/// **One entry per schedule, the latest write.** Every write is the whole
/// schedule, so an edit queued behind an earlier unsent one simply replaces it.
final class SyncQueueScheduleUploader: ScheduleUploading {

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(userId: String) {
        try? FileManager.default.createDirectory(at: PendingSyncStoreLocation.root, withIntermediateDirectories: true)
        fileURL = PendingSyncStoreLocation.schedulesFile(for: userId)

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func upload(_ schedule: Schedule) async throws {
        var pending = loadPending()
        pending.removeAll { $0.id == schedule.id }
        pending.append(schedule)
        try encoder.encode(pending).write(to: fileURL, options: .atomic)
    }

    func loadPending() -> [Schedule] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? decoder.decode([Schedule].self, from: data)) ?? []
    }

    /// Removes `schedule` only if it is still the queued version. A newer edit
    /// queued while this one was uploading must stay for the next flush.
    func dequeue(_ schedule: Schedule) throws {
        var pending = loadPending()
        pending.removeAll { $0.id == schedule.id && $0.updatedAt == schedule.updatedAt }
        try encoder.encode(pending).write(to: fileURL, options: .atomic)
    }
}
