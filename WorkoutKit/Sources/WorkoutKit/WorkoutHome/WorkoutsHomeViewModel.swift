//
//  File.swift
//  
//
//  Created by Findlay-Personal on 29/04/2023.
//

import Combine
import Foundation

class WorkoutsHomeViewModel: ObservableObject {
    
    var coordinator: WorkoutsHomeCoordinator?
    
    var addNewWorkoutPublisher = AddNewWorkoutPublisher()
    
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var searchText: String = ""
    @Published var workouts: [WorkoutCardModel] = []
    
    var filteredResults: [WorkoutCardModel] {
        if searchText.isEmpty {
            return workouts
        } else {
            return workouts.filter { ($0.workout.title.lowercased().contains(searchText.lowercased()) || filterForExercises($0, text: searchText)) }
        }
    }
    
    // MARK: - Initializer
    init() {
        listener()
    }
    
    func filterForExercises(_ workout: WorkoutCardModel, text: String) -> Bool {
        for exercise in workout.exercises {
            if exercise.name.lowercased().contains(text.lowercased()) {
                return true
            } else {
                continue
            }
        }
        return false
    }
    
    // MARK: - Listener
    func listener() {
        addNewWorkoutPublisher
            .sink { [weak self] in self?.addNewWorkout($0) }
            .store(in: &subscriptions)
    }
    
    // MARK: - Actions
    func addAction() {
        coordinator?.addNewWorkout(publisher: addNewWorkoutPublisher)
    }
    
    func showWorkoutAction(_ model: WorkoutCardModel) {
        coordinator?.showWorkout(model.workout, exercises: model.exercises)
    }
    
    func addNewWorkout(_ model: WorkoutCardModel) {
        workouts.append(model)
    }
}
