//
//  WorkoutKeyModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Workout Keys Model
/// Used to fetch keys for  workouts of current user
/// and to load single instances of  workouts
struct WorkoutKeyModel {
    
    ///The id of the workout to load
    var id: String
}
extension WorkoutKeyModel: FirebaseInstance {
    var internalPath: String {
        return "Workouts/\(FirebaseAuthManager.currentlyLoggedInUser.uid)/\(id)"
    }
}
