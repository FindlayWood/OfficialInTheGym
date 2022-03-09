//
//  WorkoutKeyModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Workout Keys Model
/// Model to fetch single instance of workout
/// Needs the workout id and assigned id
struct WorkoutKeyModel {
    
    ///The id of the workout to load
    var id: String
    
    /// The id of assingee
    var assignID: String
}
extension WorkoutKeyModel: FirebaseInstance {
    var internalPath: String {
        return "Workouts/\(assignID)/\(id)"
    }
}
