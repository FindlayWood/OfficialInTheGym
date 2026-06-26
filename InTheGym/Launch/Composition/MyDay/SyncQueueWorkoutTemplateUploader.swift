//
//  SyncQueueWorkoutTemplateUploader.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/06/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

final class SyncQueueWorkoutTemplateUploader: WorkoutTemplateUploading {

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(userId: String) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = documents.appendingPathComponent("PendingSync", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("workoutTemplates_\(userId).json")

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func upload(_ template: WorkoutTemplateModel) async throws {
        var pending = loadPending()
        pending.removeAll { $0.id == template.id }
        pending.append(template)
        let data = try encoder.encode(pending)
        try data.write(to: fileURL, options: .atomicWrite)
    }

    func loadPending() -> [WorkoutTemplateModel] {
        guard
            FileManager.default.fileExists(atPath: fileURL.path),
            let data = try? Data(contentsOf: fileURL)
        else { return [] }
        return (try? decoder.decode([WorkoutTemplateModel].self, from: data)) ?? []
    }

    func dequeue(id: String) throws {
        var pending = loadPending()
        pending.removeAll { $0.id == id }
        let data = try encoder.encode(pending)
        try data.write(to: fileURL, options: .atomicWrite)
    }
}
