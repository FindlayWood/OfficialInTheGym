//
//  myWorkoutStatsUploadModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

struct MyWorkoutStatsUploadModel {
    var time: Int
    
    var uploadPoints: [FirebaseMultiUploadDataPoint] {
        [FirebaseMultiUploadDataPoint(value: ServerValue.increment(1), path: totalWorkoutsPath),FirebaseMultiUploadDataPoint(value: ServerValue.increment(time as NSNumber), path: totalTimePath)]
    }
}
extension MyWorkoutStatsUploadModel {
    var totalWorkoutsPath: String {
        "MyWorkoutStats/\(UserDefaults.currentUser.uid)/totalWorkoutsComplete"
    }
    var totalTimePath: String {
        "MyWorkoutStats/\(UserDefaults.currentUser.uid)/totalWorkoutTime"
    }
}

struct MyWorkoutStatsModel: Decodable {
    var totalWorkoutsComplete: Int
    var totalWorkoutTime: Int
}
struct MyWorkoutStatsSearchModel: FirebaseInstance {
    var internalPath: String {
        "MyWorkoutStats/\(UserDefaults.currentUser.uid)"
    }
}
