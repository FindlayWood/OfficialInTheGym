//
//  ExerciseUpdateModels.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - RPE Update Model
struct RPEUpdateModel {
    var workoutID: String
    var exercise: ExerciseModel
}
extension RPEUpdateModel: FirebaseInstance {
    var internalPath: String {
        return "Workouts/\(UserDefaults.currentUser.uid)/\(workoutID)/exercises/\(exercise.workoutPosition)/rpe"
    }
}

// MARK: - Set Update Model
struct SetUpdateModel {
    var workoutID: String
    var exercise: ExerciseModel
    var setNumber: Int
}
extension SetUpdateModel: FirebaseInstance {
    var internalPath: String {
        return "Workouts/\(FirebaseAuthManager.currentlyLoggedInUser.uid)/\(workoutID)/exercises/\(exercise.workoutPosition)/completedSets/\(setNumber)"
    }
}

// MARK: - Start Workout Model
struct StartWorkoutModel {
    var workout: WorkoutModel
}
extension StartWorkoutModel: FirebaseInstance {
    var internalPath: String {
        return "Workouts/\(FirebaseAuthManager.currentlyLoggedInUser.uid)/\(workout.id)/startTime"
    }
}
