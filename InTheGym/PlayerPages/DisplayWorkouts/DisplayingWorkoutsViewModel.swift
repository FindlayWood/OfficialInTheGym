//
//  DisplayingWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/11/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine
import CloudKit

class DisplayingWorkoutsViewModel {
    
    // MARK: - Publisher
    var workouts = CurrentValueSubject<[WorkoutModel],Never>([])
    var errorFetching = PassthroughSubject<Error,Never>()
    
    var selectedWorkout: WorkoutModel?
    
    var updateListener = WorkoutUpdatedListener()
    
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


