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

import Firebase

struct UpdateExerciseStatsModel {
    var exerciseName: String
    var rpe: Int
    
    var points: [FirebaseMultiUploadDataPoint] {
        [completionPoint, totalRPEPoint, exerciseNamePoint]
    }
}
extension UpdateExerciseStatsModel {
    var exerciseNamePath: String {
        "ExerciseStats/\(UserDefaults.currentUser.uid)/\(exerciseName)/exerciseName"
    }
    var exerciseNamePoint: FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: exerciseName, path: exerciseNamePath)
    }
    var completionPath: String {
        "ExerciseStats/\(UserDefaults.currentUser.uid)/\(exerciseName)/numberOfCompletions"
    }
    var completionPoint: FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: ServerValue.increment(1), path: completionPath)
    }
    var totalRPEPath: String {
        "ExerciseStats/\(UserDefaults.currentUser.uid)/\(exerciseName)/totalRPE"
    }
    var totalRPEPoint: FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: ServerValue.increment(rpe as NSNumber), path: totalRPEPath)
    }
}

struct UpdateExerciseSetStatsModel {
    var exerciseName: String
    var reps: Int
    var weight: String?
    
    var points: [FirebaseMultiUploadDataPoint] {
        [exerciseNamePoint, totalRepsPoint, totalSetsPoint, totalWeightPoint]
    }
    
    var weightNumber: Double {
        if let weight = weight {
            return getWeight(from: poundsOrKilograms(from: weight) ?? .kg(0.0))
        } else {
            return 0.0
        }
    }
    func checkMax() {
        FirebaseAPIWorkoutManager.shared.checkMaxWeight(exercise: exerciseName, weight: weightNumber)
    }
    
    private let kilogramSuffix = "kg"
    private let poundsSuffix = "lbs"
}
extension UpdateExerciseSetStatsModel {
    var totalWeightPath: String {
        "ExerciseStats/\(UserDefaults.currentUser.uid)/\(exerciseName)/totalWeight"
    }
    var totalRepsPath: String {
        "ExerciseStats/\(UserDefaults.currentUser.uid)/\(exerciseName)/numberOfRepsCompleted"
    }
    var totalSetsPath: String {
        "ExerciseStats/\(UserDefaults.currentUser.uid)/\(exerciseName)/numberOfSetsCompleted"
    }
    var exerciseNamePath: String {
        "ExerciseStats/\(UserDefaults.currentUser.uid)/\(exerciseName)/exerciseName"
    }
}
extension UpdateExerciseSetStatsModel {
    var exerciseNamePoint: FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: exerciseName, path: exerciseNamePath)
    }
    var totalRepsPoint: FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: ServerValue.increment(reps as NSNumber), path: totalRepsPath)
    }
    var totalSetsPoint: FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: ServerValue.increment(1), path: totalSetsPath)
    }
    var totalWeightPoint: FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: ServerValue.increment(weightNumber as NSNumber), path: totalWeightPath)
    }
}




extension UpdateExerciseSetStatsModel {
    private func convertToKG(from pounds: Double) -> Double {
        return pounds / 2.205
    }
    private func poundsOrKilograms(from string: String) -> Weight? {
        let lastTwoChar = string.suffix(2)
        let lastThreeChar = string.suffix(3)
        if lastTwoChar == kilogramSuffix {
            let weightString = string.dropLast(2)
            if let weight = Double(weightString) {
                return .kg(weight)
            } else {
                return nil
            }
        } else if lastThreeChar == poundsSuffix {
            let weightString = string.dropLast(3)
            if let weight = Double(weightString) {
                return .lbs(weight)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    private func getWeight(from weight: Weight) -> Double {
        switch weight {
        case.kg(let kilos):
            return kilos
        case .lbs(let pounds):
            return convertToKG(from: pounds)
        }
    }
}
