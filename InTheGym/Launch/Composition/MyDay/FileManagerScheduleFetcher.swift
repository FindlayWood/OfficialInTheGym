//
//  FileManagerScheduleFetcher.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Reads `Documents/Schedules/{userId}/{id}.json`, the counterpart to
/// `FileManagerScheduleWriter`, which every save writes to first.
///
/// **The ISO-8601 date strategy must stay in step with the writer.** Changing one
/// side alone silently stops every file decoding.
final class FileManagerScheduleFetcher: ScheduleFetching {

    private let decoder: JSONDecoder
    private let directory: URL

    init(userId: String) {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        directory = ScheduleStoreLocation.directory(for: userId)
    }

    func fetchAll() async throws -> [Schedule] {
        // The directory is only created on first save; none yet is no
        // schedules, not a failure.
        guard FileManager.default.fileExists(atPath: directory.path) else { return [] }

        let files = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        )

        // Per file: one that cannot be read, such as a frequency this version
        // does not know, must not take every other schedule off MyDay.
        return files
            .filter { $0.pathExtension == "json" }
            .compactMap { url in
                do {
                    return try decoder.decode(Schedule.self, from: Data(contentsOf: url))
                } catch {
                    print("❌ Skipping local schedule \(url.lastPathComponent): \(error)")
                    return nil
                }
            }
    }
}
