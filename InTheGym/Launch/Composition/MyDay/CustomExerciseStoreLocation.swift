//
//  CustomExerciseStoreLocation.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// The one definition of where locally saved custom exercises live:
/// `Documents/CustomExercises/{userId}/{exerciseId}.json`.
///
/// **Scoped by user id, because the device is shared** — the shape
/// `WorkoutTemplateStoreLocation` settled on after the flat template directory
/// showed one account's workouts to the next. The writer, the reader (step 5 of
/// `CUSTOM_EXERCISES_PLAN.md`) and account deletion's local erase all derive
/// their path from here.
enum CustomExerciseStoreLocation {

    /// `Documents/CustomExercises`.
    static var root: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("CustomExercises", isDirectory: true)
    }

    /// `Documents/CustomExercises/{userId}`.
    static func directory(for userId: String) -> URL {
        root.appendingPathComponent(userId, isDirectory: true)
    }
}
