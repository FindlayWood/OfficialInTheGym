//
//  WorkoutCommentModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Workout Comment
/// Model to search for all comments for a given workout
struct WorkoutCommentSearchModel {
    var savedWorkoutID: String
}
extension WorkoutCommentSearchModel: FirebaseInstance {
    var internalPath: String {
        return "WorkoutComments/\(savedWorkoutID)"
    }
}
