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
    
    // MARK: - Exercise Types
    var exercises = CurrentValueSubject<[ExerciseType],Never>([])
    
    var exerciseModels = [ExerciseModel]()
    var circuitModels = [CircuitModel]()
    var emomModels = [EMOMModel]()
    var amrapModels = [AMRAPModel]()
    
    // MARK: - Publishers
    @Published var workoutTitle: String = ""
    
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
}

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
