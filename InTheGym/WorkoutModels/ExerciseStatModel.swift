//
//  ExerciseStatModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

struct ExerciseStatsModel: Codable {
    
    var totalNumberOfRepsCompleted: Int
    var totalNumberOfSetsCompleted: Int
    var totalWeightLifted: Double
    var totalRPEScore: Int
    var maxWeightLifted: Double //always stored in kg
    var totalNumberOfCompletions: Int
}
