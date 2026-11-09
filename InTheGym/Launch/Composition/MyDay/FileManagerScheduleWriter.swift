//
//  FileManagerScheduleWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Writes `Documents/Schedules/{userId}/{id}.json`. This path only.
///
/// **Written first, and it must succeed.** A schedule made with no signal has to
/// be on MyDay at once, and `ScheduleManager` reads this store before the
/// network, so the remote copy follows rather than leads.
///
/// **The ISO-8601 date strategy must stay in step with the reader.** Changing one
/// side alone silently stops every file decoding. It stores whole seconds, which
/// is why `ScheduleManager` stamps `updatedAt` in whole seconds too.
final class FileManagerScheduleWriter: ScheduleUploading {

    private let encoder: JSONEncoder
    private let directory: URL

    init(userId: String) {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        directory = ScheduleStoreLocation.directory(for: userId)
    }

    func upload(_ schedule: Schedule) async throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try encoder.encode(schedule)
        let fileURL = directory.appendingPathComponent("\(schedule.id).json")
        try data.write(to: fileURL, options: .atomic)
    }
}
