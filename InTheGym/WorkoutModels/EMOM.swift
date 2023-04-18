//
//  EMOM.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

struct EMOMModel: ExerciseType, Codable, Hashable {
    var id: String = UUID().uuidString
    var emomPosition: Int
    var workoutPosition: Int
    var exercises: [ExerciseModel]
    var timeLimit: Int
    var completed: Bool
    var rpe: Int?
    var started: Bool
    var startTime: TimeInterval?
}
