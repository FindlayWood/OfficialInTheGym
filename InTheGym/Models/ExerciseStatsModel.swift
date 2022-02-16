//
//  ExerciseStatsModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

// MARK: - Exercise Stats Model
struct ExerciseStatsModel: Hashable {
    var exerciseName: String
    var maxWeight: Double
    var maxWeightDate: TimeInterval?
    var numberOfCompletions: Int
    var numberOfRepsCompleted: Int
    var numberOfSetsCompleted: Int
    var totalRPE: Int
    var totalWeight: Double
}
extension ExerciseStatsModel {
    func averageWeight() -> Double {
        let average = totalWeight / Double(numberOfSetsCompleted)
        return average.rounded(toPlaces: 2)
    }
    func averageRPE() -> Double {
        let average = Double(totalRPE) / Double(numberOfCompletions)
        return average.rounded(toPlaces: 1)
    }
}
extension ExerciseStatsModel: FirebaseResource {
    var internalPath: String {
        return "ExerciseStats/\(UserDefaults.currentUser.uid)/\(exerciseName)"
    }
    static var path: String {
        return "ExerciseStats/\(UserDefaults.currentUser.uid)"
    }
}
