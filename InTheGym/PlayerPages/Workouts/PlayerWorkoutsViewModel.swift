//
//  PlayerWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class PlayerWorkoutsViewModel {
    
    // MARK: - Publisher
    @Published var workouts: [WorkoutModel] = []
//    var workouts = CurrentValueSubject<[WorkoutModel],Never>([])
    var errorFetching = PassthroughSubject<Error,Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Function
    @MainActor
    func fetchWorkouts() {
        Task {
            do {
                let models: [WorkoutModel] = try await apiService.fetchAsync()
                workouts = models.reversed()
            } catch {
                errorFetching.send(error)
            }
        }
    }
    
    func workoutSelected(at indexPath: IndexPath) -> WorkoutModel {
//        let currentModels = workouts.value
        let currentModels = workouts
        return currentModels[indexPath.row]
    }
}

// MARK: - Workout List
extension PlayerWorkoutsViewModel: WorkoutsList {
    func addWorkout(_ workout: WorkoutModel) {
//        var currentWorkouts = workouts.value
//        currentWorkouts.append(workout)
//        workouts.send(currentWorkouts)
        workouts.append(workout)
    }
}
