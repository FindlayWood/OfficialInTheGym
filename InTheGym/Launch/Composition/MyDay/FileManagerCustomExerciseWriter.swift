//
//  FileManagerCustomExerciseWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Writes `Documents/CustomExercises/{userId}/{id}.json`. This path only.
///
/// **Written first, and it must succeed.** An exercise made with no signal has
/// to be pickable at once, and the picker reads this store before the network
/// (step 5 of `CUSTOM_EXERCISES_PLAN.md`) — so the remote copies follow, they
/// do not lead.
///
/// **The ISO-8601 date strategy must stay in step with the reader.** Changing
/// one side alone silently stops every file decoding, which is the template
/// store's rule too.
final class FileManagerCustomExerciseWriter: CustomExerciseUploading {

    private let encoder: JSONEncoder
    private let directory: URL

    init(userId: String) {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        directory = CustomExerciseStoreLocation.directory(for: userId)
    }

    func upload(_ exercise: CustomExercise) async throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try encoder.encode(exercise)
        let fileURL = directory.appendingPathComponent("\(exercise.id).json")
        try data.write(to: fileURL, options: .atomic)
    }
}
