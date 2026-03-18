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
    
    // MARK: - Listener
    func workoutListener() {
        workoutManager.workoutsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.workouts = $0 }
            .store(in: &subscriptions)
    }
    
    // MARK: - Actions
    func addAction() {
        coordinator?.addNewWorkout()
    }
    
    func showWorkoutAction(_ model: RemoteWorkoutModel) {
        coordinator?.showWorkout(model)
    }
}
