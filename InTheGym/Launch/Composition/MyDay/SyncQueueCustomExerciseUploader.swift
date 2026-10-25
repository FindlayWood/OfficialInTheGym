//
//  SyncQueueCustomExerciseUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Holds custom exercises whose remote write failed, at
/// `Documents/PendingSync/customExercises_{userId}.json`, until
/// `CustomExerciseSyncService` flushes them.
///
/// **One entry per exercise, the latest write.** Every write is the whole
/// exercise, so an edit queued behind an earlier unsent one simply replaces it.
final class SyncQueueCustomExerciseUploader: CustomExerciseUploading {

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(userId: String) {
        try? FileManager.default.createDirectory(at: PendingSyncStoreLocation.root, withIntermediateDirectories: true)
        fileURL = PendingSyncStoreLocation.customExercisesFile(for: userId)

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func upload(_ exercise: CustomExercise) async throws {
        var pending = loadPending()
        pending.removeAll { $0.id == exercise.id }
        pending.append(exercise)
        try encoder.encode(pending).write(to: fileURL, options: .atomic)
    }

    func loadPending() -> [CustomExercise] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? decoder.decode([CustomExercise].self, from: data)) ?? []
    }

    /// Removes `exercise` only if it is still the queued version. A newer edit
    /// queued while this one was uploading must stay for the next flush.
    func dequeue(_ exercise: CustomExercise) throws {
        var pending = loadPending()
        pending.removeAll { $0.id == exercise.id && $0.updatedAt == exercise.updatedAt }
        try encoder.encode(pending).write(to: fileURL, options: .atomic)
    }
}
