//
//  WorkoutSearchModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Workout Search Model
/// Search for all workouts of given user
struct WorkoutSearchModel {
   
    /// The id of user to search
    var id: String
}
extension WorkoutSearchModel: FirebaseInstance {
    var internalPath: String {
        return "Workouts/\(id)"
    }
}
