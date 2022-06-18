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
    var editedExercise = PassthroughSubject<ExerciseModel,Never>()
    var editAction = PassthroughSubject<ExerciseSet,Never>()
    /// update publishers
    var updatedCircuit = PassthroughSubject<CircuitModel,Never>()
    var updatedAMRAP = PassthroughSubject<AMRAPModel,Never>()
    var updatedEMOM = PassthroughSubject<EMOMModel,Never>()
    // MARK: - Properties
    var workout: WorkoutModel!
    var showExerciseDetail: ExerciseModel?
    
    lazy var exercises: [ExerciseType] = {
        var exercises = [ExerciseType]()
        exercises.append(contentsOf: workout.exercises ?? [])
        exercises.append(contentsOf: workout.circuits ?? [])
        exercises.append(contentsOf: workout.amraps ?? [])
        exercises.append(contentsOf: workout.emoms ?? [])
        return exercises.sorted(by: { $0.workoutPosition < $1.workoutPosition} )
    }()
    func getClips() -> [WorkoutClipModel] {
        guard let clips = workout.clipData else {return []}
        return clips
    }
    var isEditable: Bool {
        workout.startTime != nil && !(workout.completed)
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    func initSubscriptions() {
        editedExercise
            .sink { [weak self] in self?.editedExercise($0)}
            .store(in: &subscriptions)
        updatedCircuit
            .sink { [weak self] in self?.updateCircuit($0)}
            .store(in: &subscriptions)
        updatedAMRAP
            .sink { [weak self] in self?.updateAMRAP($0)}
            .store(in: &subscriptions)
        updatedEMOM
            .sink { [weak self] in self?.updateEMOM($0)}
            .store(in: &subscriptions)
    }
    
    // MARK: - Updating Functions
    func completeSet(at index: IndexPath) {
        guard var exercise = exercises[index.section] as? ExerciseModel else {return}
        exercise.completedSets?[index.item] = true
        let uploadPoint = workout.getSetUploadPoint(exercise, setNumber: index.item)
        apiService.multiLocationUpload(data: [uploadPoint]) { [weak self] result in
            switch result {
            case .success(()):
                self?.updateExerciseModels(with: exercise)
                self?.updatedExercise.send(exercise)
            case .failure(_): break
            }
        }
        DispatchQueue.global(qos: .background).async {
            let statsUpdateModel = UpdateExerciseSetStatsModel(exerciseName: exercise.exercise, reps: exercise.reps?[index.item] ?? 0, weight: exercise.weight?[index.item] ?? "",
                                                               time: exercise.time?[index.item] ?? 0, distance: exercise.distance?[index.item] ?? "")
            self.apiService.multiLocationUpload(data: statsUpdateModel.points) { _ in }
//            FirebaseAPIWorkoutManager.shared.checkForExerciseStats(name: exercise.exercise, reps: exercise.reps?[index.item] ?? 0, weight: exercise.weight?[index.item] ?? "")
        }
    }
    
    func updateRPE(at index: IndexPath, to score: Int) {
        guard var exercise = exercises[index.item] as? ExerciseModel else {return}
        exercise.rpe = score
        let uploadPoint = workout.getRPEUploadPoint(exercise)
        apiService.multiLocationUpload(data: [uploadPoint]) { [weak self] result in
            switch result {
            case .success(()):
                self?.updateExerciseModels(with: exercise)
                self?.updatedExercise.send(exercise)
            case .failure(_): break
            }
        }
        DispatchQueue.global(qos: .background).async {
            let completionModel = UpdateExerciseStatsModel(exerciseName: exercise.exercise, rpe: score)
            self.apiService.multiLocationUpload(data: completionModel.points) { _ in }
//            FirebaseAPIWorkoutManager.shared.checkForCompletionStats(name: exercise.exercise, rpe: score)
        }
    }
    func editedExercise(_ exercise: ExerciseModel) {
        updateExerciseModels(with: exercise)
        let uploadModel = LiveWorkoutExerciseModel(workout: workout, exercise: exercise)
        guard let uploadPoints = uploadModel.addExerciseModel() else {return}
        apiService.multiLocationUpload(data: uploadPoints) { result in
            switch result {
            case .success(_): break
            case .failure(_): break
            }
        }
    }
    func updateExerciseModels(with newExercise: ExerciseModel) {
        exercises[newExercise.workoutPosition] = newExercise
        let exercises = exercises.filter { $0 is ExerciseModel }
        let exerciseModels = exercises.map { ($0 as! ExerciseModel)}
        workout.exercises = exerciseModels
    }
    // MARK: - Update Functions
    func updateCircuit(_ circuit: CircuitModel) {
        exercises[circuit.workoutPosition] = circuit
        let circuits = exercises.filter { $0 is CircuitModel }
        let circuitModels = circuits.map { ($0 as! CircuitModel) }
        workout.circuits = circuitModels
    }
    func updateAMRAP(_ amrap: AMRAPModel) {
        exercises[amrap.workoutPosition] = amrap
        let amraps = exercises.filter { $0 is AMRAPModel }
        let amrapModels = amraps.map { ($0 as! AMRAPModel) }
        workout.amraps = amrapModels
    }
    func updateEMOM(_ emom: EMOMModel) {
        exercises[emom.workoutPosition] = emom
        let emoms = exercises.filter { $0 is EMOMModel }
        let emomModels = emoms.map { ($0 as! EMOMModel)}
        workout.emoms = emomModels
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
        if workout.clipData != nil {
            workout.clipData?.append(workoutClipModel)
        } else {
            workout.clipData = [workoutClipModel]
        }
        addedClipPublisher.send(workoutClipModel)
    }

}
