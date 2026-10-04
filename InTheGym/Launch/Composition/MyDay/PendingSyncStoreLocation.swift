//
//  PendingSyncStoreLocation.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation

/// The one definition of where the template sync queue lives:
/// `Documents/PendingSync/workoutTemplates_{userId}.json`, used by
/// `SyncQueueWorkoutTemplateUploader` and by account deletion's local erase.
enum PendingSyncStoreLocation {

    static var root: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("PendingSync", isDirectory: true)
    }

    static func workoutTemplatesFile(for userId: String) -> URL {
        root.appendingPathComponent("workoutTemplates_\(userId).json")
    }
}
