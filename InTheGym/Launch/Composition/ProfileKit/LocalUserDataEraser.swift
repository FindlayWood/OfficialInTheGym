//
//  LocalUserDataEraser.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation

/// Deletes this device's copies of one user's data: day files, saved
/// templates and the template sync queue, each at the location its one
/// definition gives (`MyDayStoreLocation`, `WorkoutTemplateStoreLocation`,
/// `PendingSyncStoreLocation`).
///
/// **Only for account deletion.** Signing out deliberately keeps these: they
/// are scoped by user id, so a template that has not synced is still there when
/// its owner signs back in. A deleted account will never sign back in, and its
/// data must not outlive it on a shared phone.
///
/// Missing files are fine. Someone who never used MyDay on this phone has none.
struct LocalUserDataEraser {

    let userId: String

    func erase() {
        let fileManager = FileManager.default
        for url in [
            MyDayStoreLocation.directory(for: userId),
            WorkoutTemplateStoreLocation.directory(for: userId),
            PendingSyncStoreLocation.workoutTemplatesFile(for: userId)
        ] where fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("❌ Couldn't erase \(url.lastPathComponent): \(error)")
            }
        }
    }
}
