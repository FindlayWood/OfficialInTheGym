//
//  PublicWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class PublicWorkoutsViewModel {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var workouts: [SavedWorkoutModel] = []
    @Published var searchText: String = ""
    private var storedWorkouts: [SavedWorkoutModel] = []
    private var filteredWorkouts: [SavedWorkoutModel] = []
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    public lazy var navigationTitle: String = "\(user.username) Saved Workouts"
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    var user: Users!
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func filterWorkouts(with text: String) {
        if text.isEmpty {
            workouts = storedWorkouts
        } else {
            filteredWorkouts = storedWorkouts.filter { $0.title.lowercased().contains(text.trimTrailingWhiteSpaces().lowercased())}
            workouts = filteredWorkouts
        }
    }
    // MARK: - Functions
    func initSubscribers() {
        $searchText
            .sink { [weak self] in self?.filterWorkouts(with: $0)}
            .store(in: &subscriptions)
    }
    func fetchWorkoutKeys() {
        isLoading = true
        let referencesModel = SavedWorkoutCreatorKeyModel(id: user.uid)
        apiService.fetchKeys(from: referencesModel) { [weak self] result in
            switch result {
            case .success(let keys):
                self?.loadWorkouts(from: keys)
            case .failure(_):
                self?.isLoading = false
                break
            }
        }
    }
    
    private func loadWorkouts(from keys: [String]) {
        let savedKeysModel = keys.map { SavedWorkoutKeyModel(id: $0) }
        apiService.fetchRange(from: savedKeysModel, returning: SavedWorkoutModel.self) { [weak self] result in
            switch result {
            case .success(let savedWorkoutModels):
                let filteredModels = savedWorkoutModels.filter { !($0.isPrivate)}
                self?.workouts = filteredModels
                self?.storedWorkouts = filteredModels
                self?.isLoading = false
            case .failure(_):
                self?.isLoading = false
                break
            }
        }
    }
}
