//
//  DiscoverMoreWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class DiscoverMoreWorkoutsViewModel {
    // MARK: - Publishers
    @Published var savedModels: [SavedWorkoutModel] = []
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    var navigationTitle: String = "More Workouts"
    
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func loadWorkouts() {
        apiService.fetch(SavedWorkoutModel.self) { [weak self] result in
            switch result {
            case.success(let models):
                self?.savedModels = models
            case .failure(let error):
                print(String(describing: error))
                break
            }
        }
    }
}
