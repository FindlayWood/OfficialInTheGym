//
//  PendingSyncStoreLocation.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation

/// The one definition of where the sync queues live:
/// `Documents/PendingSync/workoutTemplates_{userId}.json` and
/// `Documents/PendingSync/customExercises_{userId}.json`, used by their
/// `SyncQueue…Uploader`s and by account deletion's local erase.
enum PendingSyncStoreLocation {

    static var root: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("PendingSync", isDirectory: true)
    }

    static func workoutTemplatesFile(for userId: String) -> URL {
        root.appendingPathComponent("workoutTemplates_\(userId).json")
    }

    static func customExercisesFile(for userId: String) -> URL {
        root.appendingPathComponent("customExercises_\(userId).json")
    }
}
