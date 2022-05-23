//
//  WorkoutViewViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class WorkoutViewViewModel {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var savedWorkoutModel: SavedWorkoutModel?
    @Published var workoutModel: WorkoutModel?
    @Published var error: Error?
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func loadWorkout(from id: String, assignID: String) {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let workoutKeyModel = WorkoutKeyModel(id: id, assignID: assignID)
            WorkoutLoader.shared.load(from: workoutKeyModel) { [weak self] result in
                switch result {
                case .success(let model):
                    self?.workoutModel = model
                    self?.isLoading = false
                case .failure(let error):
                    self?.error = error
                    self?.isLoading = false
                }
            }
        }
    }
    func loadSavedWorkout(from id: String) {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let savedWorkoutKeyModel = SavedWorkoutKeyModel(id: id)
            SavedWorkoutLoader.shared.load(from: savedWorkoutKeyModel) { [weak self] result in
                switch result {
                case .success(let model):
                    self?.savedWorkoutModel = model
                    self?.isLoading = false
                case .failure(let error):
                    self?.error = error
                    self?.isLoading = false
                }
            }
        }
    }
}
