//
//  FileManagerWorkoutTemplateFetcher.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Reads workout templates back out of `Documents/WorkoutTemplates/{id}.json`
/// — the counterpart to `FileManagerWorkoutTemplateUploader`, which is what
/// `WorkoutTemplateSaver` writes to first.
///
/// Until this existed the library read from Firestore only, while writes were
/// local-first with the remote write queued behind it. A template created
/// offline, or simply faster than the sync queue drained, was therefore
/// invisible in the library it had just been saved to.
///
/// **The directory and encoding must stay in step with
/// `FileManagerWorkoutTemplateUploader`.** Both use ISO-8601 dates; changing
/// one side alone silently stops every stored template decoding.
final class FileManagerWorkoutTemplateFetcher: WorkoutTemplateFetching {

    private let decoder: JSONDecoder
    private let directory: URL

    init() {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        directory = documents.appendingPathComponent("WorkoutTemplates", isDirectory: true)
    }

    func fetchAll() async throws -> [WorkoutTemplateModel] {
        // Nothing saved yet is an empty library, not a failure — the directory
        // is only created on first write.
        guard FileManager.default.fileExists(atPath: directory.path) else { return [] }

        let files = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        )

        // Decode per file, exactly as `FirestoreWorkoutTemplateFetcher` decodes
        // per document: one template written before a non-optional field was
        // added can no longer decode, and must not take the rest of the library
        // down with it.
        return files
            .filter { $0.pathExtension == "json" }
            .compactMap { url in
                do {
                    return try decoder.decode(WorkoutTemplateModel.self, from: Data(contentsOf: url))
                } catch {
                    print("❌ Skipping local workout template \(url.lastPathComponent): \(error)")
                    return nil
                }
            }
    }
}
