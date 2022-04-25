//
//  SavedProgramDisplayViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class SavedProgramDisplayViewModel {
    
    // MARK: - Publishers
    var weekSelectedPublisher = CurrentValueSubject<Int,Never>(0)
    
    // MARK: - Properties
    var savedProgramModel: SavedProgramModel!
    
    var options: [Options] = [.assign, .review, .save, .delete]
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func getWorkoutModels(for week: Int) -> [ProgramWorkoutCellModel] {
        let models = savedProgramModel.weeks[week].workouts.map { ProgramWorkoutCellModel(workoutModel: $0) }
        return models
    }
}
