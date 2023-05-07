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
    
    var workoutManager: WorkoutManager
    
    var hasLoaded: Bool = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var workouts: [RemoteWorkoutModel] = []
    
    var filteredResults: [RemoteWorkoutModel] {
        if searchText.isEmpty {
            return workouts
        } else {
            return workouts.filter { ($0.title.lowercased().contains(searchText.lowercased())) }
        }
    }
    
    // MARK: - Initializer
    init(workoutManager: WorkoutManager) {
        self.workoutManager = workoutManager
    }
    
//    func filterForExercises(_ workout: RemoteWorkoutModel, text: String) -> Bool {
//        for exercise in workout.exercises {
//            if exercise.name.lowercased().contains(text.lowercased()) {
//                return true
//            } else {
//                continue
//            }
//        }
//        return false
//    }
    
    // MARK: - Load
    @MainActor
    func loadWorkouts() async {
        if !hasLoaded {
            isLoading = true
            do {
                try await workoutManager.loadWorkouts()
                workouts = workoutManager.workouts
                workoutListener()
                isLoading = false
                hasLoaded = true
            } catch {
                print(String(describing: error))
                isLoading = false
            }
        }
    }
    
    func workoutListener() {
        workoutManager.workoutsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.workouts = $0 }
            .store(in: &subscriptions)
    }
    
//    func newWorkoutLoaded(_ model: WorkoutCardModel) {
//        if let index = workouts.firstIndex(where: { $0.id == model.id }) {
//            workouts[index] = model
//        } else {
//            workouts.append(model)
//        }
//    }
    
    // MARK: - Listener
//    func listener() {
//        addNewWorkoutPublisher
//            .sink { [weak self] in self?.addNewWorkout($0) }
//            .store(in: &subscriptions)
//    }
    
    // MARK: - Actions
    func addAction() {
        coordinator?.addNewWorkout()
    }
    
    func showWorkoutAction(_ model: RemoteWorkoutModel) {
        coordinator?.showWorkout(model)
    }
    
    func addNewWorkout(_ model: WorkoutCardModel) {
//        workouts.append(model)
    }
}
