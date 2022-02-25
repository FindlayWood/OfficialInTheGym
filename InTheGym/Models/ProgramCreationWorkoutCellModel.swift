//
//  ProgramCreationWorkoutCellModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation


struct ProgramCreationWorkoutCellModel: Hashable {
    var id: String = UUID().uuidString
    var savedWorkout: SavedWorkoutModel
}
struct ProgramWorkoutCellModel: Hashable {
    var id: String = UUID().uuidString
    var workoutModel: WorkoutModel
}
