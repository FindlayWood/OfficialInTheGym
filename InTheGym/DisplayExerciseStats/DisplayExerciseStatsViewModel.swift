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
    
    var selectedExercise = PassthroughSubject<ExerciseStatsModel,Never>()
    var statModelPublisher = CurrentValueSubject<[ExerciseStatsModel],Never>([])
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService
    
    var unfilteredModels: [ExerciseStatsModel]!
    
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Fetch Stat Models
    func fetchStatModels() {
        isLoading = true
        apiService.fetch(ExerciseStatsModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                let sortedModels = models.sorted(by: { $0.exerciseName < $1.exerciseName })
                self?.statModelPublisher.send(sortedModels)
                self?.unfilteredModels = sortedModels
                self?.exerciseModels = sortedModels
                self?.isLoading = false
            case .failure(let error):
                print(String(describing: error))
                self?.isLoading = false
                break
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
