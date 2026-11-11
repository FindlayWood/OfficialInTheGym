//
//  FileManagerInjuryFetcher.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Reads `Documents/Injuries/{userId}/{id}.json`, the counterpart to
/// `FileManagerInjuryWriter`, which every save writes to first.
///
/// **The ISO-8601 date strategy must stay in step with the writer.** Changing one
/// side alone silently stops every file decoding.
final class FileManagerInjuryFetcher: InjuryFetching {

    private let decoder: JSONDecoder
    private let directory: URL

    init(userId: String) {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        directory = InjuryStoreLocation.directory(for: userId)
    }

    func fetchAll() async throws -> [Injury] {
        // The directory is only created on first save; none yet is no
        // injuries, not a failure.
        guard FileManager.default.fileExists(atPath: directory.path) else { return [] }

        let files = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        )

        // Per file: one that cannot be read, such as a region this version
        // does not know, must not take every other injury off MyDay.
        return files
            .filter { $0.pathExtension == "json" }
            .compactMap { url in
                do {
                    return try decoder.decode(Injury.self, from: Data(contentsOf: url))
                } catch {
                    print("❌ Skipping local injury \(url.lastPathComponent): \(error)")
                    return nil
                }
            }
    }
}
