//
//  MyDayBodyPartsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import Foundation
import MyDayKit

/// Answers DiscoverKit's `BodyPartsLoader` with MyDay's cached muscle group
/// and movement pattern loaders — the same lists, names and cache the custom
/// exercise form uses. DiscoverKit cannot import MyDayKit, so the two meet
/// here.
struct MyDayBodyPartsLoader: BodyPartsLoader {

    let muscleGroups: ExerciseMuscleGroupsLoader
    let movementPatterns: ExerciseMovementPatternsLoader

    func loadBodyParts() async throws -> DiscoverBodyParts {
        async let groups = muscleGroups.loadMuscleGroups()
        async let patterns = movementPatterns.loadMovementPatterns()
        return DiscoverBodyParts(
            muscleGroups: try await groups.map { DiscoverBodyPart(id: $0.id, name: $0.name) },
            movementPatterns: try await patterns.map { DiscoverBodyPart(id: $0.id, name: $0.name) }
        )
    }
}
