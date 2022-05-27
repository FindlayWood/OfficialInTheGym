//
//  ExerciseTagsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class ExerciseTagsViewModel {
    
    // MARK: - Publishers
    @Published var tagModels: [ExerciseTagReturnModel] = []
    var addedNewTagPublisher = PassthroughSubject<ExerciseTagReturnModel,Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    var exerciseModel: DiscoverExerciseModel!
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func loadTags() {
        let exerciseTagModel = ExerciseTagSearchModel(exerciseName: exerciseModel.exerciseName)
        apiService.fetchInstance(of: exerciseTagModel, returning: ExerciseTagReturnModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.tagModels = models
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    func initSubscriptions() {
        addedNewTagPublisher
            .sink { [weak self] in self?.tagModels.append($0)}
            .store(in: &subscriptions)
    }
}
