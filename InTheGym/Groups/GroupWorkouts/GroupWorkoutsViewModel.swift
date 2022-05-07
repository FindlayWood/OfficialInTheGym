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
    @Published var groupWorkouts: [SavedWorkoutModel] = []
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
                self?.groupWorkouts = workouts
            case .failure(let error):
                self?.errorFetchWorkouts.send(error)
            }
        }
    }
    
    // MARK: - Actions
    func addNewSavedWorkout(_ model: SavedWorkoutModel) {
        let uploadPoint = GroupWorkoutUploadModel(groupID: group.uid, savedWorkoutID: model.id).uploadPoint
        apiService.multiLocationUpload(data: [uploadPoint]) { [weak self] result in
            switch result {
            case .success(()):
                self?.groupWorkouts.append(model)
            case .failure(let error):
                self?.errorFetchWorkouts.send(error)
            }
        }
    }

}
