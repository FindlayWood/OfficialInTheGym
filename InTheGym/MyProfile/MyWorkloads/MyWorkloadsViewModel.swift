//
//  MyWorkloadsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct MyWorkloadsViewModel {
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var workloadModels: [WorkloadModel]!
    var navigationTitle: String = "Workloads"
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
}
