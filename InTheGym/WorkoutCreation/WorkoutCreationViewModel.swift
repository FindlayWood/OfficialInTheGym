//
//  WorkoutCreationViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

protocol ExerciseAdding {
    func addExercise(_ exercise: ExerciseModel)
}

class WorkoutCreationViewModel: ExerciseAdding {
    
    // MARK: - Publishers
    var exercises = CurrentValueSubject<[ExerciseType],Never>([])
    @Published var canUpload: Bool = false
    @Published var workoutTitle: String = ""
    
    var successfullyUploadedWorkout = PassthroughSubject<Bool,Never>()
    var errorUploadingWorkout = PassthroughSubject<Bool,Never>()
    
    // MARK: - Exercise Types
    var exerciseModels = [ExerciseModel]()
    var circuitModels = [CircuitModel]()
    var emomModels = [EMOMModel]()
    var amrapModels = [AMRAPModel]()
    
    // MARK: - Properties
    var workoutList: WorkoutsList!
    
    var subscriptions = Set<AnyCancellable>()
   
    var apiService: FirebaseDatabaseManagerService
    
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
        setupPublishers()
    }
    
    func setupPublishers() {
        Publishers.CombineLatest($workoutTitle, exercises)
            .map { workoutTitle, exercises in
                return workoutTitle.count > 0 && exercises.count > 0
            }
            .sink { [unowned self] valid in
                self.canUpload = valid
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Adding Functions
    func addExercise(_ exercise: ExerciseModel) {
        var currentExercises = exercises.value
        currentExercises.append(exercise)
        exercises.send(currentExercises)
        exerciseModels.append(exercise)
    }
    func addCircuit(_ circuit: CircuitModel) {
        var currentExercises = exercises.value
        currentExercises.append(circuit)
        exercises.send(currentExercises)
        circuitModels.append(circuit)
    }
    func addEMOM(_ emom: EMOMModel) {
        var currentExercises = exercises.value
        currentExercises.append(emom)
        exercises.send(currentExercises)
        emomModels.append(emom)
    }
    func addAMRAP(_ amrap: AMRAPModel) {
        var currentExercises = exercises.value
        currentExercises.append(amrap)
        exercises.send(currentExercises)
        amrapModels.append(amrap)
    }
    
    //MARK: - Actions
    func upload(to user: Users?, with options: WorkoutOptionsModel) {
        let newSavedWorkout = NewSavedWorkoutModel(savedID: UUID().uuidString,
                                              views: 0,
                                              downloads: 0,
                                              completions: 0,
                                              totalRPE: 0,
                                              totalTime: 0,
                                              createdBy: FirebaseAuthManager.currentlyLoggedInUser.username,
                                              creatorID: FirebaseAuthManager.currentlyLoggedInUser.uid,
                                              title: workoutTitle,
                                              isPrivate: options.isPrivate,
                                              exercises: exerciseModels,
                                              circuits: circuitModels,
                                              amraps: amrapModels,
                                              emoms: emomModels)
        

        
        var multiUploadPoints = [FirebaseMultiUploadDataPoint]()
        if let savedWorkoutJSON = newSavedWorkout.toFirebaseJSON() {
            multiUploadPoints.append(savedWorkoutJSON)
        }
        


        // TODO: - Upload New Workout to saved workouts
        // TODO: - Upload keys to created workouts and saved workouts
        let savedCreatorsRef = FirebaseMultiUploadDataPoint(value: true, path: "SavedWorkoutCreators/\(FirebaseAuthManager.currentlyLoggedInUser.uid)/\(newSavedWorkout.savedID)")
        multiUploadPoints.append(savedCreatorsRef)
//        var keyPaths = ["SavedWorkoutCreators/\(FirebaseAuthManager.currentlyLoggedInUser.uid)/\(newSavedWorkout.savedID)": true]
        if options.save {
//            keyPaths["SavedWorkoutReferences/\(FirebaseAuthManager.currentlyLoggedInUser.uid)/\(newSavedWorkout.savedID)"] = true
            let savedWorkoutsRef = FirebaseMultiUploadDataPoint(value: true, path: "SavedWorkoutReferences/\(FirebaseAuthManager.currentlyLoggedInUser.uid)/\(newSavedWorkout.savedID)")
            multiUploadPoints.append(savedWorkoutsRef)
        }
        
        // TODO: - If assign != nil upload workout to user
        if let assignTo = user {
            // TODO: - Create New Workout
            let newWorkout = WorkoutModel(newSavedModel: newSavedWorkout, assignTo: assignTo.uid)
            if let newWorkoutJSON = newWorkout.toFirebaseJSON() {
                multiUploadPoints.append(newWorkoutJSON)
            }
            
        }
        
        apiService.multiLocationUpload(data: multiUploadPoints) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                self.successfullyUploadedWorkout.send(true)
            case .failure(_):
                self.errorUploadingWorkout.send(true)
            }
        }
        
    }
    
    // MARK: - Updating Functions
    func updateTitle(with newTitle: String) {
        workoutTitle = newTitle
    }
    
    // MARK: - Reset Function
    func reset() {
        exercises.send([])
        exerciseModels.removeAll()
        circuitModels.removeAll()
        emomModels.removeAll()
        amrapModels.removeAll()
        updateTitle(with: "")
    }
}

// MARK: - Exercise Creation View Model
// TODO: - Move to own file
class ExerciseCreationViewModel {
    var exercise: ExerciseModel!
    var addingDelegate: ExerciseAdding!
    var workoutPosition: Int?
    var exercisekind: exerciseKind = .regular
    
    enum exerciseKind {
        case regular
        case circuit
        case emom
        case amrap
    }
    
    func addSets(_ sets: Int) {
        exercise.sets = sets
        let completedArray = Array(repeating: false, count: sets)
        exercise.completedSets = completedArray
    }
    func addReps(_ reps: [Int]) {
        exercise.reps = reps
    }
    func addWeight(_ weight: [String]) {
        exercise.weight = weight
        addingDelegate.addExercise(exercise)
    }
    func completeExercise() {
        addingDelegate.addExercise(exercise)
    }
}
