//
//  ExerciseMaxHistoryModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct ExerciseMaxHistorySearchModel {
    var exerciseName: String
}
extension ExerciseMaxHistorySearchModel: FirebaseInstance {
    var internalPath: String {
        "ExerciseMaxHistory/\(UserDefaults.currentUser.uid)/\(exerciseName)"
    }
}

struct ExerciseMaxHistoryModel: Decodable, Hashable {
    var time: TimeInterval
    var weight: Double
}
