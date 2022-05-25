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
    
    // MARK: - Publishers
    var addedClipPublisher = PassthroughSubject<WorkoutClipModel,Never>()
    var updatedExercise = PassthroughSubject<ExerciseModel,Never>()
    
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
    
    func getClips() -> [WorkoutClipModel] {
        guard let clips = workout.clipData else {return []}
        return clips
    }
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Updating Functions
    func completeSet(at index: IndexPath) {
        guard var exercise = exercises[index.section] as? ExerciseModel else {return}
        exercise.completedSets?[index.item] = true
        let uploadPoint = workout.getSetUploadPoint(exercise, setNumber: index.item)
        apiService.multiLocationUpload(data: [uploadPoint]) { [weak self] result in
            switch result {
            case .success(()):
                self?.workout.exercises?[exercise.workoutPosition] = exercise
                self?.updatedExercise.send(exercise)
            case .failure(_): break
            }
        }
        DispatchQueue.global(qos: .background).async {
            FirebaseAPIWorkoutManager.shared.checkForExerciseStats(name: exercise.exercise, reps: exercise.reps?[index.item] ?? 0, weight: exercise.weight?[index.item] ?? "")
        }
    }
    
    func updateRPE(at index: IndexPath, to score: Int) {
        guard var exercise = exercises[index.item] as? ExerciseModel else {return}
        exercise.rpe = score
        let uploadPoint = workout.getRPEUploadPoint(exercise)
        apiService.multiLocationUpload(data: [uploadPoint]) { [weak self] result in
            switch result {
            case .success(()):
                self?.workout.exercises?[exercise.workoutPosition] = exercise
                self?.updatedExercise.send(exercise)
            case .failure(_): break
            }
        }
        DispatchQueue.global(qos: .background).async {
            FirebaseAPIWorkoutManager.shared.checkForCompletionStats(name: exercise.exercise, rpe: score)
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
    func showBottomView() -> Bool {
        workout.startTime == nil
    }
    // MARK: - Actions
    func completed() {
        let currentTime = Date().timeIntervalSince1970
        guard let startTime = workout.startTime else {return}
        let timeToComplete = currentTime - startTime
        workout.timeToComplete = Int(timeToComplete)
    }
}

// MARK: - Clip Protocol
extension WorkoutDisplayViewModel: ClipAdding {
    func addClip(_ model: ClipModel) {
        let workoutClipModel = WorkoutClipModel(storageURL: model.storageURL, clipKey: model.id, exerciseName: model.exerciseName)
        addedClipPublisher.send(workoutClipModel)
    }
}
