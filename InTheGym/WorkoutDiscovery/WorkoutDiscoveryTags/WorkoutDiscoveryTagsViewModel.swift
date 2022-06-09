//
//  WorkoutDiscoveryViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class WorkoutDiscoveryTagsViewModel {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var currentTags: [ExerciseTagReturnModel] = []
    @Published var error: Error?
    var addNewTagPublisher = PassthroughSubject<ExerciseTagReturnModel,Never>()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var savedWorkoutModel: SavedWorkoutModel!
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Functions
    func loadTags() {
        let workoutTagModel = WorkoutTagSearchModel(savedWorkoutID: savedWorkoutModel.id)
        apiService.fetchInstance(of: workoutTagModel, returning: ExerciseTagReturnModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.currentTags = models
            case .failure(let error):
                print(String(describing: error))
                self?.error = error
            }
        }
    }
    func uploadNewTag(_ newTag: ExerciseTagReturnModel) {
        isLoading = true
        let uploadModel = WorkoutTagModel(tags: [], savedWorkoutModel: savedWorkoutModel)
        let uploadPoints = uploadModel.getSinglePoint(from: newTag)
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            switch result {
            case .success(_):
                self?.isLoading = false
            case .failure(let error):
                self?.error = error
                self?.isLoading = false
            }
        }
    }
    var showPlusButton: Bool {
        savedWorkoutModel.creatorID == UserDefaults.currentUser.uid
    }
    // MARK: - Subscriptions
    func initSubscriptions() {
        addNewTagPublisher
            .sink { [weak self] in self?.currentTags.append($0)}
            .store(in: &subscriptions)
        addNewTagPublisher
            .sink { [weak self] in self?.uploadNewTag($0)}
            .store(in: &subscriptions)
    }
}
