//
//  CreateEMOMViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class CreateEMOMViewModel {
    
    // MARK: - Properties
    var navigationTitle = "Create EMOM"
    
    var emomTimeLimit: Int = 600
    
    var workoutViewModel: WorkoutCreationViewModel!
    
    var workoutPosition: Int!
    
    // MARK: - Publishers
    var exercises = CurrentValueSubject<[ExerciseModel],Never>([])
    
    // MARK: - Actions
    func addEMOM() {
        let newEmom = EMOMModel(emomPosition: workoutViewModel.emomModels.count,
                                workoutPosition: workoutPosition,
                                exercises: exercises.value,
                                timeLimit: emomTimeLimit,
                                completed: false,
                                started: false)
        workoutViewModel.addEMOM(newEmom)
    }
    
//    // MARK: - Callbacks
//    var reloadTableViewClosure: (()->())?
//
//    var exercises = [exercise]() {
//        didSet {
//            reloadTableViewClosure?()
//        }
//    }
//
//    var numberOfExercises: Int {
//        return exercises.count + 1
//    }
//
//
//    func getData(at indexPath: IndexPath) -> exercise {
//        return exercises[indexPath.section]
//    }
}
extension CreateEMOMViewModel: ExerciseAdding {
    func addExercise(_ exercise: ExerciseModel) {
        var currentExercises = exercises.value
        currentExercises.append(exercise)
        exercises.send(currentExercises)
    }
    func updatedExercise(_ exercise: ExerciseModel) {
        // NULL
    }
}
