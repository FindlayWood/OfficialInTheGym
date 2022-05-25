//
//  NewWorkoutSelectionViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class NewWorkoutSelectionViewModel {
    // MARK: - Publishers
    var selectedOption = PassthroughSubject<WorkoutBuilderOptions,Never>()
    
    // MARK: - Properties
    var navigationTitle: String = "Add New Workout"
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func builderSelected(_ option: WorkoutBuilderOptions) {
        
    }
    
    // MARK: - Functions
}

enum WorkoutBuilderOptions {
    case workout
    case liveWorkout
    case savedWorkout
}
