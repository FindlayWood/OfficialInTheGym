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
    @Published var descriptionModels: [ExerciseCommentModel] = []
    @Published var rating: Double?
    @Published var ratingCount: Int?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    var addedRatingPublisher = PassthroughSubject<Int,Never>()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Properties
    var ratings: [Int]?
    var uploadedComment = PassthroughSubject<String,Never>()
    var newCommentListener = NewCommentListener()
    var exerciseModel: DiscoverExerciseModel!
    var apiService: FirebaseDatabaseManagerService
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    func initSubscriptions() {
        addedRatingPublisher
            .sink { [weak self] in self?.newRating($0)}
            .store(in: &subscriptions)
        newCommentListener
            .sink { [weak self] in self?.newComment($0)}
            .store(in: &subscriptions)
    }
    
    // MARK: - Fetch Models
    func fetchModels() {
        isLoading = true
        let fetchModel = ExerciseCommentSearchModel(exercise: exerciseModel.exerciseName)
        apiService.fetchInstance(of: fetchModel, returning: ExerciseCommentModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                let sortedModels = models.sorted(by: { $0.likeCount > $1.likeCount })
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
                    self?.ratings = []
                } else {
                    self?.ratings = ratings
                    self?.rating = ratings.average().rounded(toPlaces: 1)
                }
                self?.ratingCount = ratings.count
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    func newComment(_ text: String) {
        isLoading = true
        let descriptionModel = ExerciseCommentModel(exercise: exerciseModel.exerciseName, comment: text)
        descriptionModel.time = Date().timeIntervalSince1970
        let uploadPoints = descriptionModel.uploadPoints()
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(()):
                self.descriptionModels.insert(descriptionModel, at: 0)
                self.isLoading = false
            case .failure(let error):
                self.error = error
                self.isLoading = false
            }
        }
    }
    func newRating(_ rating: Int) {
        ratings?.append(rating)
        self.rating = ratings?.average().rounded(toPlaces: 1)
        if let ratingCount = ratingCount {
            self.ratingCount = ratingCount + 1
        }
        isLoading = true
        let ratingModel = ExerciseRatingModel(rating: rating, exerciseName: exerciseModel.exerciseName)
        apiService.multiLocationUpload(data: [ratingModel.uploadPoint]) { [weak self] result in
            switch result {
            case .success(_):
                self?.isLoading = false
            case .failure(let error):
                self?.error = error
                self?.isLoading = false
            }
        }
    }
}
