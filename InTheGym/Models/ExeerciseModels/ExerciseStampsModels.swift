//
//  ExerciseStampsModels.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct EliteExerciseStampsModel: FirebaseInstance {
    var exerciseName: String
    var internalPath: String {
        "ExerciseStamps/\(exerciseName)/EliteStamps"
    }
    func getUploadPoint() -> FirebaseMultiUploadDataPoint {
        let path = internalPath + "/\(UserDefaults.currentUser.uid)"
        return FirebaseMultiUploadDataPoint(value: true, path: path)
    }
}

struct VerifiedExerciseStampsModel: FirebaseInstance {
    var exerciseName: String
    var internalPath: String {
        "ExerciseStamps/\(exerciseName)/VerifiedStamps"
    }
    func getUploadPoint() -> FirebaseMultiUploadDataPoint {
        let path = internalPath + "/\(UserDefaults.currentUser.uid)"
        return FirebaseMultiUploadDataPoint(value: true, path: path)
    }
}
