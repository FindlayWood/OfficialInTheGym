//
//  IncrementModels.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

struct SavedWorkoutDownloadModel {
    var savedWorkout: SavedWorkoutModel
    
    func toMultipUploadPoint() -> FirebaseMultiUploadDataPoint {
        return FirebaseMultiUploadDataPoint(value: ServerValue.increment(1), path: internalPath)
    }
}
extension SavedWorkoutDownloadModel: FirebaseInstance {
    var internalPath: String {
        return "SavedWorkouts/\(savedWorkout.savedID)/downloads"
    }
}
