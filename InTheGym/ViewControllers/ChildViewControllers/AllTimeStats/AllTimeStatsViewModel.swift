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
    @MainActor
    func loadStats() {
        isLoading = true
        let searchModel = MyWorkoutStatsSearchModel()
        Task {
            do {
                let model: MyWorkoutStatsModel = try await apiService.fetchSingleInstanceAsync(of: searchModel)
                statsModel = model
            } catch {
                self.error = error
            }
        }
    }
}
