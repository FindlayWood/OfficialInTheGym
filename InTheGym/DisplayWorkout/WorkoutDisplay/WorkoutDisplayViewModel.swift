//
//  WorkoutDisplayViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class WorkoutDisplayViewModel {
    
    // MARK: - Properties
    var workout: WorkoutModel!
    
    lazy var exercises: [ExerciseType] = {
        var exercises = [ExerciseType]()
        exercises.append(contentsOf: workout.exercises ?? [])
        exercises.append(contentsOf: workout.circuits ?? [])
        exercises.append(contentsOf: workout.amraps ?? [])
        exercises.append(contentsOf: workout.emoms ?? [])
        return exercises.sorted(by: { $0.workoutPosition < $1.workoutPosition} )
    }()
    
    func getAllExercises() -> [ExerciseType] {
        var exercises = [ExerciseType]()
        exercises.append(contentsOf: workout.exercises ?? [])
        exercises.append(contentsOf: workout.circuits ?? [])
        exercises.append(contentsOf: workout.amraps ?? [])
        exercises.append(contentsOf: workout.emoms ?? [])
        return exercises.sorted(by: { $0.workoutPosition < $1.workoutPosition} )
    }
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Updating Functions
    
    func startWorkout() {
        let time = Date().timeIntervalSince1970
        workout.startTime = time
        let startUpdateModel = StartWorkoutModel(workout: workout)
        let uploadPoint = FirebaseMultiUploadDataPoint(value: time, path: startUpdateModel.internalPath)
        apiService.multiLocationUpload(data: [uploadPoint]) { result in
            switch result {
            case .success(()): break
            case .failure(_): break
            }
        }
        
    }
    func completeSet(at index: IndexPath) {
        guard let exercise = exercises[index.section] as? ExerciseModel else {return}
        exercise.completedSets[index.item] = true
        let setUpdateModel = SetUpdateModel(workoutID: workout.workoutID, exercise: exercise, setNumber: index.item)
        let uploadPoint = FirebaseMultiUploadDataPoint(value: true, path: setUpdateModel.internalPath)
        apiService.multiLocationUpload(data: [uploadPoint]) { result in
            switch result {
            case .success(()): break
            case .failure(_): break
            }
        }
        FirebaseAPIWorkoutManager.shared.checkForExerciseStats(name: exercise.exercise, reps: exercise.reps[index.item], weight: exercise.weight[index.item])
//        if let exerciseIndex = workout.exercises?.firstIndex(where: {$0.workoutPosition == index.section }) {
//            print(exerciseIndex)
//            workout.exercises?[exerciseIndex].completedSets[index.item] = true
//        }
        
//        let exercise = exercises[index.item] as! ExerciseModel
//        exercise.completedSets[index.section] = true
    }
    
    func updateRPE(at index: IndexPath, to score: Int) {
        guard let exercise = exercises[index.item] as? ExerciseModel else {return}
        exercise.rpe = score
        let rpeUpdateModel = RPEUpdateModel(workoutID: workout.workoutID, exercise: exercise)
        let uploadPoint = FirebaseMultiUploadDataPoint(value: score, path: rpeUpdateModel.internalPath)
        apiService.multiLocationUpload(data: [uploadPoint]) { result in
            switch result {
            case .success(()): break
            case .failure(_): break
            }
        }
    }
    
    // MARK: - Retreive Function
    func isInteractionEnabled() -> Bool {
        if workout.startTime != nil && !workout.completed {
            return true
        } else {
            return false
        }
    }
    // MARK: - Actions
    func completed() {
        
    }
}
