//
//  DescriptionsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class DescriptionsViewModel {
    
    // MARK: - Publishers
    var descriptionModels = CurrentValueSubject<[DescriptionModel],Never>([])
    
    // MARK: - Properties
    var newDescriptionListener = NewDescriptionListener()
    
    var exerciseModel: DiscoverExerciseModel!
    
    var apiService: FirebaseDatabaseManagerService
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Models
    func fetchModels() {
        let fetchModel = Descriptions(exercise: exerciseModel.exerciseName)
        apiService.fetchInstance(of: fetchModel, returning: DescriptionModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                let sortedModels = models.sorted(by: { $0.vote > $1.vote })
                self?.descriptionModels.send(sortedModels)
            case .failure(_):
                break
            }
        }
    }
}
