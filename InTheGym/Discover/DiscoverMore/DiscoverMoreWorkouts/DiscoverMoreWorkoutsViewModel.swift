//
//  DiscoverMoreWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class DiscoverMoreWorkoutsViewModel {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var workouts: [SavedWorkoutModel] = []
    @Published var searchText: String = ""
    private var storedWorkouts: [SavedWorkoutModel] = []
    private var filteredWorkouts: [SavedWorkoutModel] = []
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    var navigationTitle: String = "More Workouts"
    
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
    @MainActor
    func loadWorkouts() {
        isLoading = true
        Task {
            do {
                let models: [SavedWorkoutModel] = try await apiService.fetchAsync()
                let filteredModels = models.filter { !($0.isPrivate) }
                workouts = filteredModels
                storedWorkouts = filteredModels
                isLoading = false
            } catch {
                print(String(describing: error))
                isLoading = false
            }
        }
    }
}
