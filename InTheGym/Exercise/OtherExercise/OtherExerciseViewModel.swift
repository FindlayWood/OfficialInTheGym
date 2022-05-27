//
//  OtherExerciseViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class OtherExerciseViewModel {
    
    // MARK: - Publishers
    @Published var text: String = ""
    @Published var isValid: Bool = false
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    var exerciseModel: ExerciseModel!
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func initSubscriptions() {
        $text
            .map { $0.count > 1 }
            .sink { [weak self] in self?.isValid = $0 }
            .store(in: &subscriptions)
    }
}
