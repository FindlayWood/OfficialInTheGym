//
//  ExerciseRatingModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct ExerciseRatingModel {
    var rating: Int
    var exerciseName: String
}
extension ExerciseRatingModel {
    var uploadPath: String {
        "ExerciseRating/\(exerciseName)/\(UserDefaults.currentUser.uid)"
    }
    var uploadPoint: FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: rating, path: uploadPath)
    }
}
extension ExerciseRatingModel: FirebaseInstance {
    var internalPath: String {
        "ExerciseRating/\(exerciseName)"
    }
}


struct ExerciseRatingUserModel: FirebaseInstance {
    var exerciseName: String
    var internalPath: String {
        "ExerciseRating/\(exerciseName)/\(UserDefaults.currentUser.uid)"
    }
}
