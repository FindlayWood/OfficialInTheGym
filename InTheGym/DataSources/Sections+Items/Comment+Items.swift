//
//  Comment+Items.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

enum ExerciseAndWorkoutCommentItems: Hashable {
    case exercise(ExerciseCommentModel)
    case workout(WorkoutCommentModel)
}
