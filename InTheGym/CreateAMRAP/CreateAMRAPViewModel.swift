//
//  CreateAMRAPViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class CreateAMRAPViewModel {
    
    // MARK: - Publishers
    var exercises = CurrentValueSubject<[ExerciseModel],Never>([])
    
    // MARK: - Properties
    var workoutViewModel: WorkoutCreationViewModel!
    
    var workoutPosition: Int!

    var timeLimit: Int = 10
    
    // MARK: - Actions
    func addAMRAP() {
        let newAMRAP = AMRAPModel(workoutPosition: workoutPosition,
                                  timeLimit: timeLimit,
                                  exercises: exercises.value, completed: false,
                                  roundsCompleted: 0,
                                  exercisesCompleted: 0,
                                  started: false)
        workoutViewModel.addAMRAP(newAMRAP)
    }
    
}

// MARK: - Conforming to Exercise Adding
/// Allows exercises to be added to this amrap
extension CreateAMRAPViewModel: ExerciseAdding {
    func addExercise(_ exercise: ExerciseModel) {
        var currentExercises = exercises.value
        currentExercises.append(exercise)
        exercises.send(currentExercises)
    }
}
