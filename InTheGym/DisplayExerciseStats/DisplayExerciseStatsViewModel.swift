//
//  DisplayExerciseStatsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase
import Combine

class DisplayExerciseStatsViewModel: ObservableObject {
    
    // MARK: - Publishers
    @Published var isLoading = false
    @Published var exerciseModels: [ExerciseStatsModel] = []
    @Published var searchText: String = ""
    
    var selectedExercise = PassthroughSubject<ExerciseStatsModel,Never>()
    var statModelPublisher = CurrentValueSubject<[ExerciseStatsModel],Never>([])
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService
    
    var unfilteredModels: [ExerciseStatsModel]!
    
    var filteredModels: [ExerciseStatsModel] {
        if searchText.isEmpty {
            return exerciseModels
        } else {
            return exerciseModels.filter { $0.exerciseName.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Stat Models
    @MainActor
    func fetchStatModels() {
        isLoading = true
        Task {
            do {
                let models: [ExerciseStatsModel] = try await apiService.fetchAsync()
                let sortedModels = models.sorted(by: { $0.exerciseName < $1.exerciseName })
                statModelPublisher.send(sortedModels)
                unfilteredModels = sortedModels
                exerciseModels = sortedModels
                isLoading = false
            } catch {
                print(String(describing: error))
                isLoading = false
            }
        }
    }
    
    func filterExercises(from input: String) {
        if input.isEmpty {
            statModelPublisher.send(unfilteredModels)
        } else {
            let filteredModels = unfilteredModels.filter( { $0.exerciseName.lowercased().contains(input.lowercased()) } )
            statModelPublisher.send(filteredModels)
        }
    }
    
    // MARK: - Actions
    func exerciseSelected(_ model: ExerciseStatsModel) {
        selectedExercise.send(model)
    }
}
