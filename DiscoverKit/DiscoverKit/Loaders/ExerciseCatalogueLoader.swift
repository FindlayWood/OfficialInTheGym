//
//  ExerciseCatalogueLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 10/10/2026.
//

import Foundation

/// Every visible exercise card, in any order — the whole catalogue, which
/// `CatalogueExerciseSearchLoader` searches on the device. Small and curated,
/// which is the only reason loading all of it is reasonable; nothing that
/// grows with users (workouts, people) may be read this way.
public protocol ExerciseCatalogueLoader {
    func allExercises() async throws -> [DiscoverExerciseCard]
}
