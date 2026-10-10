//
//  ExerciseSearchLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import Foundation

/// Visible exercise cards matching `query`, already normalised by
/// `DiscoverSearchQuery`, best match first. Unlike workouts and people this is
/// answered on the device — `CatalogueExerciseSearchLoader` — so it can match
/// inside a word and forgive a typo.
public protocol ExerciseSearchLoader {
    func exercises(matching query: String, limit: Int) async throws -> [DiscoverExerciseCard]
}
