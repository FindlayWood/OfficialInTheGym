//
//  File.swift
//  
//
//  Created by Findlay-Personal on 23/04/2023.
//

import Foundation

class WorkoutCreationHomeViewModel: ObservableObject, WorkoutCreation {
    
    @Published var exercises: [RemoteExerciseModel] = []
    @Published var tags: [TagModel] = []
    @Published var title: String = ""
    @Published var isPrivate: Bool = false
    @Published var isSaving: Bool = true
    
    var factory: RemoteModelFactory
    
    var workoutManager: WorkoutManager
    
    var coordinator: CreationCoordinator?
    
    var canCreateWorkout: Bool {
        !title.isEmpty && exercises.count > 0
    }
    
    var exerciseCount: Int {
        exercises.count
    }
    
    init(workoutManager: WorkoutManager, factory: RemoteModelFactory) {
        self.workoutManager = workoutManager
        self.factory = factory
    }
   
    func addNewExerciseAction() {
        coordinator?.addNewExercise(self)
    }
    
    func addExercise(_ model: RemoteExerciseModel) {
        exercises.append(model)
    }
    
    func addTag(_ text: String) {
        tags.append(.init(tag: text))
    }
    
    func createNewWorkoutAction() {
        let newWorkout = factory.makeRemoteWorkoutModel(title: title, isPrivate: isPrivate, exerciseCount: exercises.count)
        workoutManager.addNew(newWorkout)
        coordinator?.popBack()
    }
}

protocol WorkoutCreation {
    func addExercise(_ model: RemoteExerciseModel)
    var exerciseCount: Int { get }
}

class PreviewWorkoutCreation: WorkoutCreation {
    var exerciseCount: Int {
        0
    }
    func addExercise(_ model: RemoteExerciseModel) {
        
    }
}
