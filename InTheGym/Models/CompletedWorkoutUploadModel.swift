//
//  CompletedWorkoutUploadModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Completed Workout Upload Model
struct CompletedWorkoutUploadModel {
    var workout: WorkoutModel!
    
    func uploadPoints() -> [FirebaseMultiUploadDataPoint] {
        var points = [FirebaseMultiUploadDataPoint]()
        points.append(FirebaseMultiUploadDataPoint(value: true, path: completedPath))
        points.append(FirebaseMultiUploadDataPoint(value: workout.workload as Any, path: workloadPath))
        points.append(FirebaseMultiUploadDataPoint(value: workout.score as Any, path: scorePath))
        points.append(FirebaseMultiUploadDataPoint(value: workout.timeToComplete as Any, path: timePath))
        return points
    }
}

extension CompletedWorkoutUploadModel {
    var completedPath: String {
        return "Workouts/\(UserDefaults.currentUser.uid)/\(workout.workoutID)/completed"
    }
    var workloadPath: String {
        return "Workouts/\(UserDefaults.currentUser.uid)/\(workout.workoutID)/workload"
    }
    var scorePath: String {
        return "Workouts/\(UserDefaults.currentUser.uid)/\(workout.workoutID)/score"
    }
    var timePath: String {
        return "Workouts/\(UserDefaults.currentUser.uid)/\(workout.workoutID)/timeToComplete"
    }
}
