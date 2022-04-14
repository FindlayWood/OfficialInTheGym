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
    func updatedExercise(_ exercise: ExerciseModel)
}

class WorkoutCreationViewModel: ExerciseAdding {
    
    // MARK: - Publishers
    var exercises = CurrentValueSubject<[ExerciseType],Never>([])
    @Published var canUpload: Bool = false
    @Published var workoutTitle: String = ""
    
    var successfullyUploadedWorkout = PassthroughSubject<Bool,Never>()
    var errorUploadingWorkout = PassthroughSubject<Bool,Never>()
    
    var workoutListPublisher: WorkoutList!
    
    // MARK: - Exercise Types
    var exerciseModels = [ExerciseModel]()
    var circuitModels = [CircuitModel]()
    var emomModels = [EMOMModel]()
    var amrapModels = [AMRAPModel]()
    
    // MARK: - Properties
    var workoutList: WorkoutsList!
    
    var isSaving: Bool = true
    
    var isPrivate: Bool = false
    
    // MARK: - Assign To User
    /// The user to assign this workout to - if nil then just adding to created workouts with save option
    var assignTo: Users?
    
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
    func updatedExercise(_ exercise: ExerciseModel) {
        // NULL
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
    func upload() {
        let newSavedWorkout = SavedWorkoutModel(title: workoutTitle,
                                                isPrivate: isPrivate,
                                                exercises: exerciseModels,
                                                circuits: circuitModels,
                                                amraps: amrapModels,
                                                emoms: emomModels)
        
        apiService.uploadTimeOrderedModel(model: newSavedWorkout) { [weak self] result in
            switch result {
            case .success(let model):
//                print(model)
                self?.uploadDatabaseLocations(for: model)
            case .failure(_):
                break
            }
        }
    }
    
    func uploadDatabaseLocations(for model: SavedWorkoutModel) {
        var multiUploadPoints = [FirebaseMultiUploadDataPoint]()

        let savedCreatorsRef = FirebaseMultiUploadDataPoint(value: true, path: "SavedWorkoutCreators/\(UserDefaults.currentUser.uid)/\(model.id)")
        multiUploadPoints.append(savedCreatorsRef)
        
        if isSaving {
            let savedWorkoutsRef = FirebaseMultiUploadDataPoint(value: true, path: "SavedWorkoutReferences/\(UserDefaults.currentUser.uid)/\(model.id)")
            multiUploadPoints.append(savedWorkoutsRef)
        }
        
        if let assignTo = assignTo {
            let newWorkout = WorkoutModel(savedModel: model, assignTo: assignTo.uid)
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
        case live
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
    func appendToReps(_ reps: Int) {
        if var currentReps = exercise.reps {
            currentReps.append(reps)
            exercise.reps = currentReps
        } else {
            exercise.reps = [reps]
        }
        
        exercise.sets += 1
        if var currentSets = exercise.completedSets {
            currentSets.append(true)
            exercise.completedSets = currentSets
        } else {
            exercise.completedSets = [true]
        }
//        exercise.completedSets.append(true)
    }
    func appendToWeight(_ weight: String) {
        if var currentWeight = exercise.weight {
            currentWeight.append(weight)
            exercise.weight = currentWeight
        } else {
            exercise.weight = [weight]
        }
//        exercise.weight.append(weight)
        addingDelegate.updatedExercise(exercise)
    }
}
