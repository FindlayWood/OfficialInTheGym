//
//  File.swift
//  
//
//  Created by Findlay-Personal on 30/04/2023.
//

import Foundation

class WorkoutDisplayViewModel: ObservableObject {
    
    var workoutModel: WorkoutModel
    var exercises: [ExerciseModel]

    init(workoutModel: WorkoutModel, exercises: [ExerciseModel]) {
        self.workoutModel = workoutModel
        self.exercises = exercises
    }
    
}
