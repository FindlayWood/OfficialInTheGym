//
//  SavedWorkoutsDisplayViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

class SavedWorkoutDisplayViewModel {
    
    var savedWorkout: SavedWorkoutModel!
    
    lazy var exercises: [ExerciseType] = {
        var exercises = [ExerciseType]()
        exercises.append(contentsOf: savedWorkout.exercises ?? [])
        exercises.append(contentsOf: savedWorkout.circuits ?? [])
        exercises.append(contentsOf: savedWorkout.amraps ?? [])
        exercises.append(contentsOf: savedWorkout.emoms ?? [])
        return exercises.sorted(by: { $0.workoutPosition < $1.workoutPosition} )
    }()
}
