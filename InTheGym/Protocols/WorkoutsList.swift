//
//  WorkoutsList.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Workout List
/// a type (usually a view model) that has a workouts list and can add a new workout to list
protocol WorkoutsList {
    
    // TODO: - Needs to accept WorkoutModel and SavedWorkoutModel
    func addWorkout(_ workout: WorkoutModel)
}
