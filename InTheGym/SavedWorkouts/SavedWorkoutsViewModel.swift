//
//  SavedWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class SavedWorkoutsViewModel:NSObject {
    
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    var savedWorkoutss = CurrentValueSubject<[SavedWorkoutModel],Never>([])
    var errorFetchingWorkouts = PassthroughSubject<Error,Never>()

    /// listen for removal of workout
    var listRemoveListener = PassthroughSubject<SavedWorkoutModel,Never>()
    
    // MARK: - Properties
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    
    // MARK: - Fetching functions
    func fetchKeys() {
        isLoading = true
        let referencesModel = SavedWorkoutsReferences(id: UserDefaults.currentUser.uid)
        apiService.fetchKeys(from: referencesModel) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let keys):
                self.loadWorkouts(from: keys)
            case .failure(let error):
                self.errorFetchingWorkouts.send(error)
                self.isLoading = false
            }
        }
    }
    
    func loadWorkouts(from keys: [String]) {
        let savedKeysModel = keys.map { SavedWorkoutKeyModel(id: $0) }
        apiService.fetchRange(from: savedKeysModel, returning: SavedWorkoutModel.self) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let savedWorkoutModels):
                self.savedWorkoutss.send(savedWorkoutModels)
                self.isLoading = false
            case .failure(let error):
                self.errorFetchingWorkouts.send(error)
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Retieve Data
    func workoutSelected(at indexPath: IndexPath) -> SavedWorkoutModel {
        let currentWorkouts = savedWorkoutss.value
        return currentWorkouts[indexPath.row]
    }
}
