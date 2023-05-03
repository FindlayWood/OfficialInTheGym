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
    
    var apiService: NetworkService
    var userService: CurrentUserServiceWorkoutKit
    
    var addNewWorkoutPublisher: AddNewWorkoutPublisher?
    
    var coordinator: CreationCoordinator?
    
    var canCreateWorkout: Bool {
        !title.isEmpty && exercises.count > 0
    }
    
    init(apiService: NetworkService = Mock.shared, userService: CurrentUserServiceWorkoutKit = MockUserService.shared) {
        self.apiService = apiService
        self.userService = userService
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
        let newWorkout = WorkoutModel(id: UUID().uuidString, title: title, creatorID: userService.currentUserUID, assignedBy: userService.currentUserUID, isPrivate: isPrivate, completed: false)
        let newWorkoutCard = WorkoutCardModel(workout: newWorkout, exercises: exercises)
        Task {
            do {
                try await apiService.write(data: newWorkout, at: "Users/\(userService.currentUserUID)/Workouts/\(newWorkout.id)")
                for exercise in exercises {
                    try await apiService.write(data: exercise, at: "Users/\(userService.currentUserUID)/Workouts/\(newWorkout.id)/Exercises/\(exercise.id)")
                }
            } catch {
                print(String(describing: error))
            }
        }
        addNewWorkoutPublisher?.send(newWorkoutCard)
        coordinator?.popBack()
    }
}
