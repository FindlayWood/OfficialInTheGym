//
//  DiscoverPageSections+Items.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum DiscoverPageSections: String, CaseIterable {
    case Clips = "Clips"
    case Workouts = "Workouts"
    case Exercises = "Exercises"
    case Tags = "Tags"
    
}

enum DiscoverPageItems: Hashable {
    case workout(SavedWorkoutModel)
    case exercise(DiscoverExerciseModel)
    case tag(ExerciseTagReturnModel)
    case clip(ClipModel)
}
