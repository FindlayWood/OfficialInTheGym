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
    @Published var exercises: [ExerciseModel] = []
    var addedExercise = PassthroughSubject<ExerciseModel,Never>()
    var updatedExercise = PassthroughSubject<ExerciseModel,Never>()
    var updateExerciseRPE = PassthroughSubject<ExerciseModel,Never>()
    
    var addedClipPublisher = PassthroughSubject<WorkoutClipModel,Never>()
    
    // MARK: - Properties
    var showExerciseDetail: ExerciseModel?
    
    var workoutModel: WorkoutModel!
    
    var apiService: FirebaseDatabaseManagerService
    
    private var subscriptions = Set<AnyCancellable>()
    
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
    func initSubscriptions() {
        
        addedExercise
            .sink { [weak self] in self?.addExercise($0)}
            .store(in: &subscriptions)
        
        updatedExercise
            .sink { [weak self] in self?.updatedExercise($0)}
            .store(in: &subscriptions)
    }
    
    // MARK: - Actions
    func updateRPE(at index: IndexPath, to score: Int) {
        guard let currentExercises = workoutModel.exercises else {return}
        var exercise = currentExercises[index.item]
        exercise.rpe = score
        let rpeUpdateModel = RPEUpdateModel(workoutID: workoutModel.id, exercise: exercise)
        let uploadPoint = FirebaseMultiUploadDataPoint(value: score, path: rpeUpdateModel.internalPath)
        let completionModel = UpdateExerciseStatsModel(exerciseName: exercise.exercise, rpe: score)
        var points: [FirebaseMultiUploadDataPoint] = completionModel.points
        points.append(uploadPoint)
        apiService.multiLocationUpload(data: points) { [weak self] result in
            switch result {
            case .success(()):
                self?.workoutModel.exercises?[exercise.workoutPosition] = exercise
                self?.updateExerciseRPE.send(exercise)
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
//        let currentExercises = workoutModel.exercises
        return workoutModel.exercises?.count ?? 0
    }
    
    func getExercise(at indexPath: IndexPath) -> ExerciseModel {
        guard let currentExercises = workoutModel.exercises else {return ExerciseModel(workoutPosition: 0)}
        var currentExercise = currentExercises[indexPath.item]
        currentExercise.sets += 1
        currentExercise.reps?.append(1)
        currentExercise.weight?.append(" ")
        currentExercise.completedSets?.append(true)
        currentExercise.time?.append(0)
        currentExercise.distance?.append(" ")
        currentExercise.restTime?.append(0)
        currentExercise.tempo?.append(ExerciseTempoModel(eccentric: 0, eccentricPause: 0, concentric: 0, concentricPause: 0))
        return currentExercise
    }
    
    func getExerciseModel(at indexPath: IndexPath) -> ExerciseCreationViewModel {
        guard let currentExercises = workoutModel.exercises else {return ExerciseCreationViewModel()}
        let currentExercise = currentExercises[indexPath.item]
        let newViewModel = ExerciseCreationViewModel()
        newViewModel.exercise = currentExercise
        newViewModel.exercisekind = .live
        newViewModel.addingDelegate = self
        newViewModel.addCompletedSet()
        return newViewModel
    }
}

// MARK: - Exercise Adding Protocol
extension LiveWorkoutDisplayViewModel: ExerciseAdding {
    func addExercise(_ exercise: ExerciseModel) {
        if workoutModel.exercises == nil {
            workoutModel.exercises = [exercise]
        } else {
            workoutModel.exercises?.append(exercise)
        }
//        addedExercise.send(exercise)
        // TODO: - Update Firebase
        let uploadModel = LiveWorkoutExerciseModel(workout: workoutModel, exercise: exercise)
        guard let uploadPoint = uploadModel.addExerciseModel() else {return}
        apiService.multiLocationUpload(data: uploadPoint) { result in
            switch result {
            case .success(()):
                break
            case .failure(_):
                // TODO: - Connection Error
                break
            }
        }
    }
    func updatedExercise(_ exercise: ExerciseModel) {
        // TODO: - Update Firebase
        workoutModel.exercises?[exercise.workoutPosition] = exercise
        let uploadModel = LiveWorkoutExerciseModel(workout: workoutModel, exercise: exercise)
        guard let uploadPoints = uploadModel.addExerciseModel() else {return}
        let statsUpdateModel = UpdateExerciseSetStatsModel(exerciseName: exercise.exercise, reps: exercise.reps?.last ?? 0, weight: exercise.weight?.last,
                                                           time: exercise.time?.last ?? 0, distance: exercise.distance?.last)
        var points: [FirebaseMultiUploadDataPoint] = statsUpdateModel.points
        points.append(contentsOf: uploadPoints)
        apiService.multiLocationUpload(data: points) { result in
            switch result {
            case .success(()):
                statsUpdateModel.checkMax()
            case .failure(_):
                // TODO: - Connection error
                break
            }
        }
    }
}
// MARK: - Clip Protocol
extension LiveWorkoutDisplayViewModel: ClipAdding {
    func addClip(_ model: ClipModel) {
        let workoutClipModel = WorkoutClipModel(storageURL: model.storageURL, clipKey: model.id, exerciseName: model.exerciseName)
        if workoutModel.clipData != nil {
            workoutModel.clipData?.append(workoutClipModel)
        } else {
            workoutModel.clipData = [workoutClipModel]
        }
        addedClipPublisher.send(workoutClipModel)
    }
}
