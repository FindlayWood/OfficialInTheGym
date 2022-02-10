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
    var addedExercise = PassthroughSubject<ExerciseModel,Never>()
    var updatedExercise = PassthroughSubject<ExerciseModel,Never>()
    
    var addedClipPublisher = PassthroughSubject<WorkoutClipModel,Never>()
    
    // MARK: - Properties
    var workoutModel: WorkoutModel!
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    func getInitialExercises() -> [ExerciseModel] {
        guard let initialExercises = workoutModel.exercises?.sorted(by: { $0.workoutPosition < $1.workoutPosition }) else {return []}
        return initialExercises
    }
    
    func getClips() -> [WorkoutClipModel] {
        guard let clips = workoutModel.clipData else {return []}
        return clips
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
        let currentTime = Date().timeIntervalSince1970
        guard let startTime = workoutModel.startTime else {return}
        let timeToComplete = currentTime - startTime
        workoutModel.timeToComplete = Int(timeToComplete)
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
        guard let currentExercises = workoutModel.exercises else {return ExerciseCreationViewModel()}
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
//        var currentExercises = exercises.value
//        currentExercises.append(exercise)
//        exercises.send(currentExercises)
        workoutModel.exercises?.append(exercise)
//        exercises.value.append(exercise)
        addedExercise.send(exercise)
        // TODO: - Update Firebase
        let uploadModel = LiveWorkoutExerciseModel(workout: workoutModel, exercise: exercise)
        let uploadPoint = uploadModel.addExerciseModel()
        print(uploadPoint)
//        apiService.multiLocationUpload(data: uploadPoint) { [weak self] result in
//            switch result {
//            case .success(()):
//                break
//            case .failure(_):
//                // TODO: - Connection Error
//                break
//            }
//        }
    }
    func updatedExercise(_ exercise: ExerciseModel) {
        // TODO: - Update Firebase
        updatedExercise.send(exercise)
        let uploadModel = LiveWorkoutExerciseModel(workout: workoutModel, exercise: exercise)
        let uploadPoints = uploadModel.updateSetModel()
        print(uploadPoints)
//        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
//            switch result {
//            case .success(()):
//                break
//            case .failure(_):
//                // TODO: - Connection error
//                break
//            }
//        }
    }
}

// MARK: - Clip Protocol
extension LiveWorkoutDisplayViewModel: ClipAdding {
    func addClip(_ model: WorkoutClipModel) {
        addedClipPublisher.send(model)
    }
}
