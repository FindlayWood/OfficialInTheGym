//
//  ScheduleStoreLocation.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// The one definition of where locally saved schedules live:
/// `Documents/Schedules/{userId}/{scheduleId}.json`.
///
/// **Scoped by user id, because the device is shared**, the shape
/// `WorkoutTemplateStoreLocation` settled on after the flat template directory
/// showed one account's workouts to the next. The writer, the reader and account
/// deletion's local erase all derive their path from here.
enum ScheduleStoreLocation {

    /// `Documents/Schedules`.
    static var root: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("Schedules", isDirectory: true)
    }

    /// `Documents/Schedules/{userId}`.
    static func directory(for userId: String) -> URL {
        root.appendingPathComponent(userId, isDirectory: true)
    }
}
