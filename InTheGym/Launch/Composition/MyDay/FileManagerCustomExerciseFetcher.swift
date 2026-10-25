//
//  FileManagerCustomExerciseFetcher.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Reads `Documents/CustomExercises/{userId}/{id}.json` — the counterpart to
/// `FileManagerCustomExerciseWriter`, which every save writes to first. It is
/// what makes an exercise created offline pickable at once.
///
/// **The ISO-8601 date strategy must stay in step with the writer.** Changing
/// one side alone silently stops every file decoding.
final class FileManagerCustomExerciseFetcher: CustomExerciseFetching {

    private let decoder: JSONDecoder
    private let directory: URL

    init(userId: String) {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        directory = CustomExerciseStoreLocation.directory(for: userId)
    }

    func fetchAll() async throws -> [CustomExercise] {
        // The directory is only created on first save; none yet is no
        // exercises, not a failure.
        guard FileManager.default.fileExists(atPath: directory.path) else { return [] }

        let files = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        )

        // Per file, as the template fetcher decodes: one file that cannot be
        // read must not empty the user's whole list.
        return files
            .filter { $0.pathExtension == "json" }
            .compactMap { url in
                do {
                    return try decoder.decode(CustomExercise.self, from: Data(contentsOf: url))
                } catch {
                    print("❌ Skipping local custom exercise \(url.lastPathComponent): \(error)")
                    return nil
                }
            }
    }
}
