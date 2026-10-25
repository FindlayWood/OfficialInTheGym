//
//  CachedExerciseBodyLoaders.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// The muscle group and movement pattern readers, cached on disk, built in one
/// place. MyDay's custom exercise form and DISCOVER's "Works" section both use
/// them; building the stack once per composition from here keeps it one
/// reader per collection over one cache, rather than two copies of the wiring
/// that could drift apart.
enum CachedExerciseBodyLoaders {

    static func muscleGroups() -> ExerciseMuscleGroupsLoader {
        CachedExerciseMuscleGroupsLoader(
            remote: RemoteMuscleGroupsLoader(),
            cache: FileExerciseBodyListCache(url: ExerciseBodyListStoreLocation.muscleGroups)
        )
    }

    static func movementPatterns() -> ExerciseMovementPatternsLoader {
        CachedExerciseMovementPatternsLoader(
            remote: RemoteMovementTypesLoader(),
            cache: FileExerciseBodyListCache(url: ExerciseBodyListStoreLocation.movementPatterns)
        )
    }
}
