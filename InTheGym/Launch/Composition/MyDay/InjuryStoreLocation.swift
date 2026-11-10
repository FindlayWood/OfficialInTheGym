//
//  InjuryStoreLocation.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// The one definition of where locally saved injuries live:
/// `Documents/Injuries/{userId}/{injuryId}.json`.
///
/// **Scoped by user id, because the device is shared**, the shape
/// `WorkoutTemplateStoreLocation` settled on after the flat template directory
/// showed one account's workouts to the next. The writer, the reader and account
/// deletion's local erase all derive their path from here.
enum InjuryStoreLocation {

    /// `Documents/Injuries`.
    static var root: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("Injuries", isDirectory: true)
    }

    /// `Documents/Injuries/{userId}`.
    static func directory(for userId: String) -> URL {
        root.appendingPathComponent(userId, isDirectory: true)
    }
}
