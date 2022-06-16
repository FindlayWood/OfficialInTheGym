//
//  PerformanceMonitorViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct PerformanceMonitorViewModel {
    // MARK: - Publishers
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var navigationTitle: String = "Performance Monitor"
    var user: Users!
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
}
