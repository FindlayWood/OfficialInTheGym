//
//  ProfileLibraryLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import Foundation

/// Loads every workout in the signed-in user's library, private ones included, newest first, for
/// **All workouts** on their own profile.
///
/// The composition root answers it from MyDay's own library manager, which reads the device first.
/// A workout saved offline is therefore listed straight away. Reading Firestore directly would hide
/// it until it synced, the defect that once emptied MyDay's library.
public protocol ProfileLibraryLoader {
    func allWorkouts() async throws -> [ProfileWorkout]
}
