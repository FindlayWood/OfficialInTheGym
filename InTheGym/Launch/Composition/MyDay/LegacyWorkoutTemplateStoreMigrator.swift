//
//  LegacyWorkoutTemplateStoreMigrator.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Moves templates written before the local store was scoped by user —
/// `Documents/WorkoutTemplates/{id}.json` — into
/// `Documents/WorkoutTemplates/{createdBy}/{id}.json`.
///
/// **Filed by the template's own `createdBy`, never by whoever is signing in
/// now.** Those files are the pooled output of every account that has used the
/// device, which is the bug being fixed; attributing them to the current user
/// would hand them all to one person and leave the library showing exactly the
/// workouts it should not.
///
/// A file that cannot be decoded is left where it is rather than deleted. It was
/// already invisible — `FileManagerWorkoutTemplateFetcher` has always skipped
/// undecodable files, and a template written before `exerciseName` became
/// non-optional can never decode again — so there is nothing to gain by
/// destroying it, and its owner cannot be read off it anyway.
///
/// Idempotent, and cheap once it has run: the root then holds only the per-user
/// directories, which the `json` filter skips.
struct LegacyWorkoutTemplateStoreMigrator {

    private let fileManager: FileManager
    private let decoder: JSONDecoder

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func migrate() {
        let root = WorkoutTemplateStoreLocation.root

        // The directory is only created on first write, so its absence is a
        // device that has never saved a template, not a failure.
        guard fileManager.fileExists(atPath: root.path) else { return }

        guard let contents = try? fileManager.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: nil
        ) else { return }

        for url in contents where url.pathExtension == "json" {
            migrateFile(at: url)
        }
    }

    private func migrateFile(at url: URL) {
        guard
            let data = try? Data(contentsOf: url),
            let template = try? decoder.decode(WorkoutTemplateModel.self, from: data)
        else {
            print("❌ Leaving unreadable legacy workout template \(url.lastPathComponent) in place")
            return
        }

        let directory = WorkoutTemplateStoreLocation.directory(for: template.createdBy)
        let destination = directory.appendingPathComponent(url.lastPathComponent)

        // Already migrated — the scoped copy is the one being read, so the
        // legacy file is a duplicate and goes.
        guard !fileManager.fileExists(atPath: destination.path) else {
            try? fileManager.removeItem(at: url)
            return
        }

        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            try fileManager.moveItem(at: url, to: destination)
        } catch {
            // Leaving it at the root costs the owner one template until the next
            // launch retries; moving it somewhere unreadable would cost it for good.
            print("❌ Could not migrate workout template \(url.lastPathComponent): \(error)")
        }
    }
}
