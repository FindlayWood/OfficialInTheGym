//
//  CoachPlayerWorkoutViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

class CoachPlayerWorkoutViewModel {
    
    // MARK: - Publishers
    
    // MARK: - Properties
    var workoutModel: WorkoutModel!
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func getAllExercises() -> [ExerciseType] {
        var exercises = [ExerciseType]()
        exercises.append(contentsOf: workoutModel.exercises ?? [])
        exercises.append(contentsOf: workoutModel.circuits ?? [])
        exercises.append(contentsOf: workoutModel.amraps ?? [])
        exercises.append(contentsOf: workoutModel.emoms ?? [])
        return exercises.sorted(by: { $0.workoutPosition < $1.workoutPosition} )
    }
    
    func getClips() -> [WorkoutClipModel] {
        guard let clips = workoutModel.clipData else {return []}
        return clips
    }
}
