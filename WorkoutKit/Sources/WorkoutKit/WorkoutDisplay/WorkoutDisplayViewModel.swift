//
//  File.swift
//  
//
//  Created by Findlay-Personal on 30/04/2023.
//

import Foundation

class WorkoutDisplayViewModel: ObservableObject {
    
    @Published var selectedSet: SetController?
    
    var workoutModel: WorkoutModel
    var exercises: [ExerciseController]

    init(workoutModel: WorkoutModel, exercises: [ExerciseModel]) {
        self.workoutModel = workoutModel
        self.exercises = exercises.map { ExerciseController(exerciseModel: $0) }
    }
    
}
