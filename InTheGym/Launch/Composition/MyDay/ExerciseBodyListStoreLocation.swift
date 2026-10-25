//
//  ExerciseBodyListStoreLocation.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// The one definition of where the muscle group and movement pattern lists are
/// kept on disk: `Documents/ExerciseBody/{list}.json`.
///
/// **Not scoped by user id**, unlike every other local store. These are the
/// catalogue's lists, the same for everyone, and hold nothing of the user's —
/// so there is nothing to leak to the next account on a shared device and
/// nothing for `LocalUserDataEraser` to remove.
enum ExerciseBodyListStoreLocation {

    /// `Documents/ExerciseBody`.
    static var root: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("ExerciseBody", isDirectory: true)
    }

    static var muscleGroups: URL {
        root.appendingPathComponent("muscleGroups.json")
    }

    static var movementPatterns: URL {
        root.appendingPathComponent("movementPatterns.json")
    }
}
