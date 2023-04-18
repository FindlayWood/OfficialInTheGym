//
//  IncrementModels.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

// MARK: - Saved Workout Download Increment
struct SavedWorkoutDownloadModel {
    var savedWorkout: SavedWorkoutModel
    
    func toMultipUploadPoint() -> FirebaseMultiUploadDataPoint {
        return FirebaseMultiUploadDataPoint(value: ServerValue.increment(1), path: internalPath)
    }
}
extension SavedWorkoutDownloadModel: FirebaseInstance {
    var internalPath: String {
        return "SavedWorkouts/\(savedWorkout.id)/downloads"
    }
}

// MARK: - AMRAP
///Rounds and Exercise Increment or Set Completed
struct AMRAPUpdateModel {
    var workout: WorkoutModel
    var amrap: AMRAPModel
    var type: AMRAPUpdateType
    
    func uploadModel() -> FirebaseMultiUploadDataPoint {
        switch type {
        case .rounds, .exercises:
            return FirebaseMultiUploadDataPoint(value: ServerValue.increment(1), path: internalPath)
        case .completed:
            return FirebaseMultiUploadDataPoint(value: true, path: internalPath)
        case .rpe(let score):
            return FirebaseMultiUploadDataPoint(value: score, path: internalPath)
        }
    }
    
    func pathEnding() -> String {
        switch type {
        case .rounds:
            return "roundsCompleted"
        case .exercises:
            return "exercisesCompleted"
        case .completed:
            return "completed"
        case .rpe(_):
            return "rpe"
        }
    }
}
extension AMRAPUpdateModel: FirebaseInstance {
    var internalPath: String {
        return "Workouts/\(FirebaseAuthManager.currentlyLoggedInUser.uid)/\(workout.id)/amraps/\(amrap.amrapPosition)/\(pathEnding())"
    }
}

// MARK: - Stats
///Update Exercise Stats
struct ExerciseStatsUpdateModel {
    
}
