//
//  File.swift
//  
//
//  Created by Findlay-Personal on 23/04/2023.
//

import Foundation

class WorkoutCreationHomeViewModel: ObservableObject {
    
    @Published var exercises: [ExerciseModel] = []
    @Published var tags: [TagModel] = []
    @Published var title: String = ""
    @Published var isPrivate: Bool = false
    @Published var isSaving: Bool = true
    
    var addNewWorkoutPublisher: AddNewWorkoutPublisher?
    
    var coordinator: CreationCoordinator?
    
    var canCreateWorkout: Bool {
        !title.isEmpty && exercises.count > 0
    }
    
    func addNewExerciseAction() {
        coordinator?.addNewExercise(self)
    }
    
    func addExercise(_ model: ExerciseModel) {
        exercises.append(model)
    }
    
    func addTag(_ text: String) {
        tags.append(.init(tag: text))
    }
    
    func createNewWorkoutAction() {
        let newWorkout = WorkoutModel(id: UUID().uuidString, title: title, creatorID: "", assignedBy: "", isPrivate: isPrivate, completed: false)
        let newWorkoutCard = WorkoutCardModel(workout: newWorkout, exercises: exercises)
        addNewWorkoutPublisher?.send(newWorkoutCard)
        coordinator?.popBack()
    }
}
