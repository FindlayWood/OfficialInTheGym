//
//  PlayerDetailViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class PlayerDetailViewModel {
    // MARK: - Publishers
    @Published var profileImageData: Data?
    // MARK: - Properties
    var navigationTitle = "Player Detail"
    
    var user: Users!
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
}
