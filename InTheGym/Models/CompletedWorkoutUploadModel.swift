//
//  CompletedWorkoutUploadModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

// MARK: - Completed Workout Upload Model
struct CompletedWorkoutUploadModel {
    var workout: WorkoutModel!
    
    func uploadPoints() -> [FirebaseMultiUploadDataPoint] {
        var points = [FirebaseMultiUploadDataPoint]()
        points.append(FirebaseMultiUploadDataPoint(value: true, path: completedPath))
        points.append(FirebaseMultiUploadDataPoint(value: workout.workload as Any, path: workloadPath))
        points.append(FirebaseMultiUploadDataPoint(value: workout.score as Any, path: scorePath))
        points.append(FirebaseMultiUploadDataPoint(value: workout.timeToComplete as Any, path: timePath))
        if workout.savedID != nil {
            points.append(FirebaseMultiUploadDataPoint(value: ServerValue.increment(NSNumber(value: workout.timeToComplete!)), path: savedTotalTimePath))
            points.append(FirebaseMultiUploadDataPoint(value: ServerValue.increment(NSNumber(value: workout.score!)), path: savedTotalRPEPath))
            points.append(FirebaseMultiUploadDataPoint(value: ServerValue.increment(1), path: savedCompletionsPath))
        }
        return points
    }
}

extension CompletedWorkoutUploadModel {
    var completedPath: String {
        return "Workouts/\(UserDefaults.currentUser.uid)/\(workout.id)/completed"
    }
    var workloadPath: String {
        return "Workouts/\(UserDefaults.currentUser.uid)/\(workout.id)/workload"
    }
    var scorePath: String {
        return "Workouts/\(UserDefaults.currentUser.uid)/\(workout.id)/score"
    }
    var timePath: String {
        return "Workouts/\(UserDefaults.currentUser.uid)/\(workout.id)/timeToComplete"
    }
    var savedTotalTimePath: String {
        guard let savedID = workout.savedID else {return ""}
        return "SavedWorkouts/\(savedID)/totalTime"
    }
    var savedTotalRPEPath: String {
        guard let savedID = workout.savedID else {return ""}
        return "SavedWorkouts/\(savedID)/totalRPE"
    }
    var savedCompletionsPath: String {
        guard let savedID = workout.savedID else {return ""}
        return "SavedWorkouts/\(savedID)/completions"
    }
}
