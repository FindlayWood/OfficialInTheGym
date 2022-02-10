//
//  LiveWorkoutSections+Items.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum SingleSection {
    case main
}

enum LiveWorkoutSections {
    case exercise
    case plus
}

enum LiveWorkoutItems: Hashable {
    case exercise(ExerciseModel)
    case plus
}

enum LiveWorkoutSetItems: Hashable {
    case exerciseSet(ExerciseSet)
    case plus
}

