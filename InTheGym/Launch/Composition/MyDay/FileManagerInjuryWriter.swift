//
//  FileManagerInjuryWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Writes `Documents/Injuries/{userId}/{id}.json`. This path only.
///
/// **Written first, and it must succeed.** An injury rated with no signal has
/// to be on MyDay at once, and `InjuryManager` reads this store before the
/// network, so the remote copy follows rather than leads.
///
/// **The ISO-8601 date strategy must stay in step with the reader.** Changing one
/// side alone silently stops every file decoding. It stores whole seconds, which
/// is why `InjuryManager` stamps `updatedAt` in whole seconds too.
final class FileManagerInjuryWriter: InjuryUploading {

    private let encoder: JSONEncoder
    private let directory: URL

    init(userId: String) {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        directory = InjuryStoreLocation.directory(for: userId)
    }

    func upload(_ injury: Injury) async throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try encoder.encode(injury)
        let fileURL = directory.appendingPathComponent("\(injury.id).json")
        try data.write(to: fileURL, options: .atomic)
    }
}
