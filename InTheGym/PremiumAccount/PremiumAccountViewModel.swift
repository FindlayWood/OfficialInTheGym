//
//  PremiumAccountViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

class PremiumAccountViewModel {
    // MARK: - Publishers
    @Published var selectedSubscription: SubscriptionEnum = .monthly
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Actions
    
    // MARK: - Functions
}
