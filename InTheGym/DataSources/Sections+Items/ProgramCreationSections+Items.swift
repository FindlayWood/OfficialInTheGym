//
//  ProgramCreationSections+Items.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum ProgramCreationWorkoutSections {
    case workouts
    case plus
}

enum ProgramCreationWorkoutItems: Hashable {
    case workout(ProgramCreationWorkoutCellModel)
    case plus
}

enum WeeksSection {
    case number
    case plus
}
enum WeeksItems: Hashable {
    case number(Int)
    case plus
}
