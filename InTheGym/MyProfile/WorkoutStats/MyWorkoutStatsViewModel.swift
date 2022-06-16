//
//  MyWorkoutStatsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class MyWorkoutStatsViewModel {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var myStatsModel: MyWorkoutStatsModel?
    @Published var error: Error?
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var selectedIndex: Int = 0
    var navigationTitle: String {
        "My Workout Stats"
    }
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func loadStats() {
        isLoading = true
        let searchModel = MyWorkoutStatsSearchModel()
        apiService.fetchSingleInstance(of: searchModel, returning: MyWorkoutStatsModel.self) { [weak self] result in
            defer { self?.isLoading = false }
            switch result {
            case .success(let model):
                self?.myStatsModel = model
            case .failure(let error):
                self?.error = error
            }
        }
    }
}
