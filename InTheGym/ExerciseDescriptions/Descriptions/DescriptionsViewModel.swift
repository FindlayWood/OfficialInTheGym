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
    @Published var descriptionModels: [DescriptionModel] = []
    @Published var rating: Double?
    @Published var ratingCount: Int?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    var addedRatingPublisher = PassthroughSubject<Int,Never>()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Properties
    var newDescriptionListener = NewDescriptionListener()
    var exerciseModel: DiscoverExerciseModel!
    var apiService: FirebaseDatabaseManagerService
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    func initSubscriptions() {
        addedRatingPublisher
            .sink { [weak self] _ in self?.loadRating()}
            .store(in: &subscriptions)
    }
    
    // MARK: - Fetch Models
    func fetchModels() {
        isLoading = true
        let fetchModel = Descriptions(exercise: exerciseModel.exerciseName)
        apiService.fetchInstance(of: fetchModel, returning: DescriptionModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                let sortedModels = models.sorted(by: { $0.vote > $1.vote })
                self?.descriptionModels = sortedModels
                self?.isLoading = false
            case .failure(let error):
                self?.error = error
                self?.isLoading = false
            }
        }
    }
    func loadRating() {
        let ratingModel = ExerciseRatingModel(rating: 0, exerciseName: exerciseModel.exerciseName)
        apiService.fetchSingleObjectInstance(of: ratingModel, returning: Int.self) { [weak self] result in
            switch result {
            case .success(let ratings):
                if ratings.isEmpty {
                    self?.rating = 0
                } else {
                    self?.rating = ratings.average().rounded(toPlaces: 1)
                }
                self?.ratingCount = ratings.count
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
}
