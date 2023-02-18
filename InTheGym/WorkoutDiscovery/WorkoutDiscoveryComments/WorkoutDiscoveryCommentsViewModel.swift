//
//  WorkoutDiscoveryCommentsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class WorkoutDiscoveryCommentsViewModel {
    // MARK: - Publishers
    @Published var commentModels: [WorkoutCommentModel] = []
    @Published var rating: Double?
    @Published var userRating: Int?
    @Published var ratingCount: Int?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    var addedRatingPublisher = PassthroughSubject<Int,Never>()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Properties
    var ratings: [Int]?
    var newCommentListener = NewCommentListener()
    var savedWorkoutModel: SavedWorkoutModel!
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
        let fetchModel = WorkoutCommentSearchModel(savedWorkoutID: savedWorkoutModel.id)
        apiService.fetchInstance(of: fetchModel, returning: WorkoutCommentModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                let sortedModels = models.sorted(by: { $0.likeCount > $1.likeCount })
                self?.commentModels = sortedModels
                self?.isLoading = false
            case .failure(let error):
                self?.error = error
                self?.isLoading = false
            }
        }
    }
    func loadRating() {
        let ratingModel = WorkoutRatingModel(rating: 0, savedWorkoutID: savedWorkoutModel.id)
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
    func getUserRating() {
        let ratingModel = WorkoutRatingUserModel(savedWorkoutID: savedWorkoutModel.id)
        apiService.fetchSingleInstance(of: ratingModel, returning: Int.self) { [weak self] result in
            switch result {
            case .success(let rating):
                self?.userRating = rating
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }
    func newComment(_ text: String) {
        isLoading = true
        let commentModel = WorkoutCommentModel(model: savedWorkoutModel, comment: text)
        commentModel.time = Date().timeIntervalSince1970
        let uploadPoints = commentModel.uploadPoints()
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            switch result {
            case .success(_):
                self?.commentModels.append(commentModel)
                self?.isLoading = false
            case .failure(let error):
                self?.error = error
                self?.isLoading = false
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
        let ratingModel = WorkoutRatingModel(rating: rating, savedWorkoutID: savedWorkoutModel.id)
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
