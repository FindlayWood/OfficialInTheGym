//
//  DisplaySingleSetViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

struct DisplaySingleSetViewModel {
    // MARK: - Publishers
    var editSetAction: PassthroughSubject<ExerciseSet,Never>?
    
    // MARK: - Properties
    var isEditable: Bool?
    var setModel: ExerciseSet!
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
}
