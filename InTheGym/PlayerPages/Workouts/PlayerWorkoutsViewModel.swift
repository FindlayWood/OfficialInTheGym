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
    var workouts = CurrentValueSubject<[WorkoutModel],Never>([])
    var errorFetching = PassthroughSubject<Error,Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Function
    func fetchWorkouts() {
        apiService.fetch(WorkoutModel.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let models):
                self.workouts.send(models)
            case .failure(let error):
                self.errorFetching.send(error)
            }
        }
    }
    
    func workoutSelected(at indexPath: IndexPath) -> WorkoutModel {
        let currentModels = workouts.value
        return currentModels[indexPath.row]
    }
}

// MARK: - Workout List
extension PlayerWorkoutsViewModel: WorkoutsList {
    func addWorkout(_ workout: WorkoutModel) {
        var currentWorkouts = workouts.value
        currentWorkouts.append(workout)
        workouts.send(currentWorkouts)
    }
}
