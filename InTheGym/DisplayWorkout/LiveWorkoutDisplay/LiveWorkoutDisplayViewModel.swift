//
//  LiveWorkoutDisplayViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class LiveWorkoutDisplayViewModel {
    
    // MARK: - Publishers
    var exercises = CurrentValueSubject<[ExerciseModel],Never>([])
    
    // MARK: - Properties
    var workoutModel: WorkoutModel!
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    func setupExercises() {
        guard let initialExercises = workoutModel.exercises?.sorted(by: { $0.workoutPosition < $1.workoutPosition }) else {return}
        exercises.send(initialExercises)
    }
    
    // MARK: - Actions
    func updateRPE(at index: IndexPath, to score: Int) {
        let currentExercises = exercises.value
        let exercise = currentExercises[index.item]
        exercise.rpe = score
        let rpeUpdateModel = RPEUpdateModel(workoutID: workoutModel.workoutID, exercise: exercise)
        let uploadPoint = FirebaseMultiUploadDataPoint(value: score, path: rpeUpdateModel.internalPath)
        apiService.multiLocationUpload(data: [uploadPoint]) { result in
            switch result {
            case .success(()): break
            case .failure(_): break
            }
        }
    }
    
    func completed() {
        
    }
    
    // MARK: - Retreive Function
    func isInteractionEnabled() -> Bool {
        if workoutModel.startTime != nil && !workoutModel.completed {
            return true
        } else {
            return false
        }
    }
    
    func getExerciseCount() -> Int {
        let currentExercises = exercises.value
        return currentExercises.count
    }
    
    func getExerciseModel(at indexPath: IndexPath) -> ExerciseCreationViewModel {
        let currentExercises = exercises.value
        let currentExercise = currentExercises[indexPath.item]
        let newViewModel = ExerciseCreationViewModel()
        newViewModel.exercise = currentExercise
        newViewModel.exercisekind = .live
        newViewModel.addingDelegate = self
        return newViewModel
    }
}

// MARK: - Exercise Adding Protocol
extension LiveWorkoutDisplayViewModel: ExerciseAdding {
    func addExercise(_ exercise: ExerciseModel) {
        var currentExercises = exercises.value
        currentExercises.append(exercise)
        exercises.send(currentExercises)
        // TODO: - Update Firebase
    }
    func updatedExercise(_ exercise: ExerciseModel) {
        // TODO: - Update Firebase
    }
}
