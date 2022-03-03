//
//  GroupWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

final class GroupWorkoutsViewModel {
    
    // MARK: - Publishers
    var workoutPublisher = CurrentValueSubject<[SavedWorkoutModel],Never>([])
    var errorFetchWorkouts = PassthroughSubject<Error,Never>()
    
    
    // MARK: - Properties
    var group: GroupModel!
    
    var navigationTitle = "Group Workouts"
    
    var groupWorkoutsLoadedSuccessfully: Bool = false
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    //MARK: - Fetching Functions
    func fetchWorkouts() {
        let fetchKeysModel = GroupWorkoutKeys(id: group.uid)
        apiService.fetchKeys(from: fetchKeysModel) { [weak self] result in
            switch result {
            case .success(let keys):
                self?.loadWorkouts(from: keys)
            case .failure(let error):
                self?.errorFetchWorkouts.send(error)
            }
        }
    }
    private func loadWorkouts(from keys: [String]) {
        let models = keys.map { SavedWorkoutKeyModel(id: $0)}
        apiService.fetchRange(from: models, returning: SavedWorkoutModel.self) { [weak self] result in
            switch result {
            case .success(let workouts):
                self?.workoutPublisher.send(workouts)
            case .failure(let error):
                self?.errorFetchWorkouts.send(error)
            }
        }
    }
    
    // MARK: - Returning Functions

}
