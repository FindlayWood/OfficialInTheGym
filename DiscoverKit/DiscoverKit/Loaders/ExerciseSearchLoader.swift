//
//  ExerciseSearchLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import Foundation

/// Visible exercise cards whose name **starts with** `query`, already
/// normalised by `DiscoverSearchQuery`. Prefix only, for the reason given on
/// `PeopleSearchLoader`.
public protocol ExerciseSearchLoader {
    func exercises(matching query: String, limit: Int) async throws -> [DiscoverExerciseCard]
}
