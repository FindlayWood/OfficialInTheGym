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

class WorkoutCreationViewModel {
    
    // MARK: - Publishers
    @Published var exercises: [ExerciseType] = []
//    var exercises = CurrentValueSubject<[ExerciseType],Never>([])
    @Published var canUpload: Bool = false
    @Published var workoutTitle: String = ""
    
    var successfullyUploadedWorkout = PassthroughSubject<Bool,Never>()
    var errorUploadingWorkout = PassthroughSubject<Bool,Never>()
    
    var workoutListPublisher: WorkoutList!
    
    var addedExercisePublisher = PassthroughSubject<ExerciseModel,Never>()
    var addedCircuitPublisher = PassthroughSubject<CircuitModel,Never>()
    var addedAmrapPublisher = PassthroughSubject<AMRAPModel,Never>()
    var addedEmomPublisher = PassthroughSubject<EMOMModel,Never>()
    
    var toggledSaving = PassthroughSubject<Void,Never>()
    var toggledPrivacy = PassthroughSubject<Void,Never>()
    var addedNewTag = PassthroughSubject<ExerciseTagReturnModel,Never>()
    // MARK: - Exercise Types
    var exerciseModels = [ExerciseModel]()
    var circuitModels = [CircuitModel]()
    var emomModels = [EMOMModel]()
    var amrapModels = [AMRAPModel]()
    
    // MARK: - Properties
    var workoutList: WorkoutsList!
    
    var isSaving: Bool = true
    
    var isPrivate: Bool = false
    
    var workoutTags: [ExerciseTagReturnModel] = []
    
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
        Publishers.CombineLatest($workoutTitle, $exercises)
            .map { workoutTitle, exercises in
                return workoutTitle.count > 0 && exercises.count > 0
            }
            .sink { [unowned self] valid in
                self.canUpload = valid
            }
            .store(in: &subscriptions)
        
        addedExercisePublisher
            .sink { [weak self] in self?.addExercise($0) }
            .store(in: &subscriptions)
        addedCircuitPublisher
            .sink { [weak self] in self?.addCircuit($0)}
            .store(in: &subscriptions)
        addedAmrapPublisher
            .sink { [weak self] in self?.addAMRAP($0)}
            .store(in: &subscriptions)
        addedEmomPublisher
            .sink { [weak self] in self?.addEMOM($0)}
            .store(in: &subscriptions)
    }
    func optionSubscriptions() {
        toggledSaving
            .sink { [weak self] in self?.isSaving.toggle()}
            .store(in: &subscriptions)
        toggledPrivacy
            .sink { [weak self] in self?.isPrivate.toggle()}
            .store(in: &subscriptions)
        addedNewTag
            .sink { [weak self] in self?.workoutTags.append($0)}
            .store(in: &subscriptions)
    }
    
    // MARK: - Adding Functions
    func addExercise(_ exercise: ExerciseModel) {
        exercises.append(exercise)
        exerciseModels.append(exercise)
    }
    func addCircuit(_ circuit: CircuitModel) {
        var circuit = circuit
        circuit.workoutPosition = exercises.count
        circuit.circuitPosition = circuitModels.count
        exercises.append(circuit)
        circuitModels.append(circuit)
    }
    func addEMOM(_ emom: EMOMModel) {
        var emom = emom
        emom.workoutPosition = exercises.count
        emom.emomPosition = emomModels.count
        exercises.append(emom)
        emomModels.append(emom)
    }
    func addAMRAP(_ amrap: AMRAPModel) {
        var amrap = amrap
        amrap.workoutPosition = exercises.count
        amrap.amrapPosition = amrapModels.count
        exercises.append(amrap)
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
            apiService.uploadTimeOrderedModel(model: newWorkout) { result in
                switch result {
                case .success(_):
                    break
                case .failure(_):
                    break
                }
            }
        }
        if !workoutTags.isEmpty {
            let workoutTagModel = WorkoutTagModel(tags: workoutTags, savedWorkoutModel: model)
            let points = workoutTagModel.getPoints()
            multiUploadPoints.append(contentsOf: points)
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
        exercises = []
        exerciseModels.removeAll()
        circuitModels.removeAll()
        emomModels.removeAll()
        amrapModels.removeAll()
        workoutTags.removeAll()
        isSaving = true
        isPrivate = false
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
        let repArray = Array(repeating: 1, count: sets)
        let weightArray = Array(repeating: " ", count: sets)
        exercise.completedSets = completedArray
        exercise.reps = repArray
        exercise.weight = weightArray
    }
    func addCompletedSet() {
        exercise.sets += 1
        if var completedArray = exercise.completedSets {
            completedArray.append(true)
            exercise.completedSets = completedArray
        } else {
            let completedArray = Array(repeating: true, count: exercise.sets)
            exercise.completedSets = completedArray
        }
        if var repArray = exercise.reps {
            repArray.append(1)
            exercise.reps = repArray
        } else {
            let repArray = Array(repeating: 1, count: exercise.sets)
            exercise.reps = repArray
        }
        if var weightArray = exercise.weight {
            weightArray.append(" ")
            exercise.weight = weightArray
        } else {
            let weightArray = Array(repeating: " ", count: exercise.sets)
            exercise.weight = weightArray
        }
        
    }
    func addReps(_ reps: [Int]) {
        exercise.reps = reps
    }
    func addWeight(_ weight: [String]) {
        exercise.weight = weight
//        addingDelegate.addExercise(exercise)
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
    
    func getSetCellModels() -> [SetCellModel] {
        var models = [SetCellModel]()
        guard let reps = exercise.reps else {return []}
        for (index, rep) in reps.enumerated() {
            let newModel = SetCellModel(setNumber: index + 1, repNumber: rep, weightString: "")
            models.append(newModel)
        }
        return models
    }
    func addTime(_ seconds: [Int]) {
        exercise.time = seconds
    }
    func addDistance(_ distance: [String]) {
        exercise.distance = distance
    }
    func addRestTime(_ seconds: [Int]){
        exercise.restTime = seconds
    }
    func addNote(_ note: String) {
        exercise.note = note
    }
}
