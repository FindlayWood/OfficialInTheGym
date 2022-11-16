//
//  CoachPlayerWorkoutsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class CoachPlayerWorkoutsViewModel {
    
    // MARK: - Publishers
    var workoutsPublisher = CurrentValueSubject<[WorkoutModel],Never>([])
    var errorPublisher = PassthroughSubject<Error,Never>()
    
    @Published var isLoading: Bool = false
    
    // MARK: - Properties
    var player: Users!
    
    lazy var navigationTitle = "\(player.username)'s Workouts"
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func loadWorkouts() {
        isLoading = true
        let workoutSearchModel = WorkoutSearchModel(id: player.uid)
        apiService.fetchInstance(of: workoutSearchModel, returning: WorkoutModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                let sortedModels = models.sorted(by: { $0.startTime ?? 0 > $1.startTime ?? 0})
                self?.workoutsPublisher.send(sortedModels)
                self?.isLoading = false
            case .failure(let error):
                self?.errorPublisher.send(error)
                self?.isLoading = false
            }
        }
    }
}
