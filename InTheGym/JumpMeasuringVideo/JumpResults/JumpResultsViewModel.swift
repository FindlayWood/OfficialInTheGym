//
//  JumpResultsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct JumpResultsViewModel {
    // MARK: - Publishers
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var jumpResultCM: Double!
    var jumpResultIN: Double {
        jumpResultCM.convertCMtoInches().rounded(toPlaces: 2)
    }
    var currentValue: Double!
    var resultCM: Bool = true
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    mutating func switchSegment(to index: Int) {
        if index == 0 {
            currentValue = jumpResultCM
            resultCM = true
        } else {
            currentValue = jumpResultIN
            resultCM = false
        }
    }
    // MARK: - Functions
}
