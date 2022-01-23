//
//  SavedWorkoutKeyModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Saved Workout Keys Model
/// Used to fetch keys for saved workouts of current user
/// and to load single instances of saved workouts
struct SavedWorkoutKeyModel {
    var id: String
}
extension SavedWorkoutKeyModel: FirebaseResource {
    static var path: String {
        return "SavedWorkoutReferences/\(FirebaseAuthManager.currentlyLoggedInUser.uid)"
    }
    var internalPath: String {
        return "SavedWorkouts/\(id)"
    }
}

// MARK: - Saved Workout Reference Model
/// used to check whether a user has saved this workout
/// and to upload a new saved workout
struct SavedWorkoutReferenceModel {
    var id: String
    
    func toMultipUploadPoint() -> FirebaseMultiUploadDataPoint {
        return FirebaseMultiUploadDataPoint(value: true, path: internalPath)
    }
}
extension SavedWorkoutReferenceModel: FirebaseInstance {
    var internalPath: String {
        return "SavedWorkoutReferences/\(FirebaseAuthManager.currentlyLoggedInUser.uid)/\(id)"
    }
}
