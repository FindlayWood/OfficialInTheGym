//
//  MyDayStoreLocation.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation

/// The one definition of where day files live:
/// `Documents/MyDays/{userId}/{yyyy-MM-dd}.json`. The same shape as
/// `WorkoutTemplateStoreLocation`, and for the same reason: the saver, the
/// loader and account deletion's local erase all need it, and three copies of a
/// path are how a store's writer and reader drift apart.
enum MyDayStoreLocation {

    /// `Documents/MyDays`, the parent of the per-user directories.
    static var root: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("MyDays", isDirectory: true)
    }

    static func directory(for userId: String) -> URL {
        root.appendingPathComponent(userId, isDirectory: true)
    }
}
