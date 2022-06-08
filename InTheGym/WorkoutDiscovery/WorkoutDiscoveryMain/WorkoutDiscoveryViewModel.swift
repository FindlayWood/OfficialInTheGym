//
//  WorkoutDiscoveryViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct WorkoutDiscoveryViewModel {
    // MARK: - Publishers
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var savedWorkoutModel: SavedWorkoutModel!
    var selectedIndex: Int = 0
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
}
