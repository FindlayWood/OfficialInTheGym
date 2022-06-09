//
//  ExerciseRatingViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class ExerciseRatingViewModel {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var ratingSelected: Bool = false
    @Published var selectedRating: Int?
    @Published var error: Error?
    var addedRatingPublisher: PassthroughSubject<Int,Never>?
    var uploadSuccessful = PassthroughSubject<Void,Never>()
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var navigationTitle: String = "Exercise Rating"
//    var exerciseModel: DiscoverExerciseModel!
    var currentRating: Double?
    var subscriptions = Set<AnyCancellable>()
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Actions
    func initSubscribers() {
        
    }
    func submitRating() {
        guard let rating = selectedRating else {return}
        addedRatingPublisher?.send(rating)
//        isLoading = true
//        guard let rating = selectedRating else {return}
//        let ratingModel = ExerciseRatingModel(rating: rating, exerciseName: exerciseModel.exerciseName)
//        apiService.multiLocationUpload(data: [ratingModel.uploadPoint]) { [weak self] result in
//            switch result {
//            case .success(_):
//                self?.addedRatingPublisher?.send(rating)
//                self?.isLoading = false
//            case .failure(let error):
//                self?.error = error
//                self?.isLoading = false
//            }
//        }
    }
    // MARK: - Functions
}
