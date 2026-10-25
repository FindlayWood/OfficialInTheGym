//
//  FileExerciseBodyListCache.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// One list kept as one JSON file. It knows exactly one path, handed in from
/// `ExerciseBodyListStoreLocation`, so the muscle group and movement pattern
/// caches are two instances rather than one cache that knows both.
///
/// Failures are swallowed on purpose: this is a cache, so a file that cannot
/// be read is the same as no file, and one that cannot be written only means
/// the next offline visit falls back to the network.
final class FileExerciseBodyListCache<Element: Codable>: @unchecked Sendable {
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func load() -> [Element]? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([Element].self, from: data)
    }

    func save(_ elements: [Element]) {
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try JSONEncoder().encode(elements).write(to: url, options: .atomic)
        } catch {
            print("❌ Could not cache \(url.lastPathComponent): \(error)")
        }
    }
}
