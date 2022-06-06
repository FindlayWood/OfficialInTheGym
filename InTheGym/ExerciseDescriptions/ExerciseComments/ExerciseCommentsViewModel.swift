//
//  ExerciseCommentsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct ExerciseCommentsViewModel {
    // MARK: - Publishers
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
}
