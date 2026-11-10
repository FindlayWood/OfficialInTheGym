//
//  SyncQueueInjuryUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Holds injuries whose remote write failed, at
/// `Documents/PendingSync/injuries_{userId}.json`, until `InjurySyncService`
/// flushes them.
///
/// **One entry per injury, the latest write.** Every write is the whole
/// injury, so an edit queued behind an earlier unsent one simply replaces it.
final class SyncQueueInjuryUploader: InjuryUploading {

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(userId: String) {
        try? FileManager.default.createDirectory(at: PendingSyncStoreLocation.root, withIntermediateDirectories: true)
        fileURL = PendingSyncStoreLocation.injuriesFile(for: userId)

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func upload(_ injury: Injury) async throws {
        var pending = loadPending()
        pending.removeAll { $0.id == injury.id }
        pending.append(injury)
        try encoder.encode(pending).write(to: fileURL, options: .atomic)
    }

    func loadPending() -> [Injury] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? decoder.decode([Injury].self, from: data)) ?? []
    }

    /// Removes `injury` only if it is still the queued version. A newer edit
    /// queued while this one was uploading must stay for the next flush.
    func dequeue(_ injury: Injury) throws {
        var pending = loadPending()
        pending.removeAll { $0.id == injury.id && $0.updatedAt == injury.updatedAt }
        try encoder.encode(pending).write(to: fileURL, options: .atomic)
    }
}
