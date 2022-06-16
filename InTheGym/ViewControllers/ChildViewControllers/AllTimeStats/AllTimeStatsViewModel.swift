//
//  AllTimeStatsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class AllTimeStatsViewModel {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var statsModel: MyWorkoutStatsModel?
    @Published var error: Error?
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Functions
    func loadStats() {
        isLoading = true
        let searchModel = MyWorkoutStatsSearchModel()
        apiService.fetchSingleInstance(of: searchModel, returning: MyWorkoutStatsModel.self) { [weak self] result in
            defer { self?.isLoading = false }
            switch result {
            case .success(let model):
                self?.statsModel = model
            case .failure(let error):
                self?.error = error
            }
        }
    }
}
