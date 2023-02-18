//
//  WorkoutRatingModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct WorkoutRatingModel {
    var rating: Int
    var savedWorkoutID: String
}
extension WorkoutRatingModel {
    var uploadPath: String {
        "WorkoutRating/\(savedWorkoutID)/\(UserDefaults.currentUser.uid)"
    }
    var uploadPoint: FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: rating, path: uploadPath)
    }
}
extension WorkoutRatingModel: FirebaseInstance {
    var internalPath: String {
        "WorkoutRating/\(savedWorkoutID)"
    }
}

struct WorkoutRatingUserModel: FirebaseInstance {
    var savedWorkoutID: String
    var internalPath: String {
        "WorkoutRating/\(savedWorkoutID)/\(UserDefaults.currentUser.uid)"
    }
}
