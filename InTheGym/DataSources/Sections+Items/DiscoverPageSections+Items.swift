//
//  DiscoverPageSections+Items.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum DiscoverPageSections: String, CaseIterable {
    case Workouts = "Workouts"
    case Exercises = "Exercises"
    case Programs = "Programs"
    case Clips = "Clips"
}

enum DiscoverPageItems: Hashable {
    case workout(SavedWorkoutModel)
    case exercise(DiscoverExerciseModel)
    case program(SavedProgramModel)
    case clip(ClipModel)
}
