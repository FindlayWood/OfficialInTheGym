//
//  LiveWorkoutExerciseModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Live Workout Exercise Model
struct LiveWorkoutExerciseModel {
    var workout: WorkoutModel!
    var exercise: ExerciseModel!
    
    func updateSetModel() -> [FirebaseMultiUploadDataPoint] {
        var uploadPoints = [FirebaseMultiUploadDataPoint]()
        // reps
        uploadPoints.append(FirebaseMultiUploadDataPoint(value: exercise.reps.last as Any, path: basePath + "/reps/\(exercise.sets - 1)"))
        // sets
        uploadPoints.append(FirebaseMultiUploadDataPoint(value: exercise.sets, path: basePath + "/sets"))
        // completedSets
        uploadPoints.append(FirebaseMultiUploadDataPoint(value: true, path: basePath + "/completedSets/\(exercise.sets - 1)"))
        // weight
        uploadPoints.append(FirebaseMultiUploadDataPoint(value: exercise.weight.last as Any, path: basePath + "/weight/\(exercise.sets - 1)"))
        return uploadPoints
    }
    
    func addExerciseModel() -> [FirebaseMultiUploadDataPoint] {
        return [FirebaseMultiUploadDataPoint(value: exercise as Any, path: basePath)]
    }
}
extension LiveWorkoutExerciseModel {
    var basePath: String {
        return "Workouts/\(UserDefaults.currentUser.uid)/\(workout.id)/exercises/\(exercise.workoutPosition)"
    }
}
