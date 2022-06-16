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
    
    var repsCompletedString: String {
        numberOfRepsCompleted.description
    }
    var maxWeightString: String {
        maxWeight.description + "kg"
    }
    var totalWeightString: String {
        totalWeight.description + "kg"
    }
    var averageWeightString: String {
        averageWeight().description + "kg"
    }
    var averageRPEString: String {
        averageRPE().description
    }
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
    var time: Int?
    var distance: String?
    
    var points: [FirebaseMultiUploadDataPoint] {
        [exerciseNamePoint, totalRepsPoint, totalSetsPoint, totalWeightPoint, totalDistancePoint, totalTimePoint]
    }
    
    var weightNumber: Double {
        if let weight = weight {
            return getWeight(from: poundsOrKilograms(from: weight) ?? .kg(0.0))
        } else {
            return 0.0
        }
    }
    var timeInSeconds: Int {
        if let time = time {
            return time
        } else {
            return 0
        }
    }
    var distanceNumber: Double {
        if let distance = distance {
            return milesOrMetres(from: distance) ?? 0.0
        } else {
            return 0.0
        }
    }
    func checkMax() {
        FirebaseAPIWorkoutManager.shared.checkMaxWeight(exercise: exerciseName, weight: weightNumber)
    }
    
    private let kilogramSuffix = "kg"
    private let poundsSuffix = "lbs"
    private let milesSuffix = "miles"
    private let kmSuffix = "km"
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
    var totalDistancePath: String {
        "ExerciseStats/\(UserDefaults.currentUser.uid)/\(exerciseName)/totalDistance"
    }
    var totalTimePath: String {
        "ExerciseStats/\(UserDefaults.currentUser.uid)/\(exerciseName)/totalTime"
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
    var totalDistancePoint: FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: ServerValue.increment(distanceNumber as NSNumber), path: totalDistancePath)
    }
    var totalTimePoint: FirebaseMultiUploadDataPoint {
        FirebaseMultiUploadDataPoint(value: ServerValue.increment(timeInSeconds as NSNumber), path: totalTimePath)
    }
}
// MARK: - Weight Extraction
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
// MARK: - Distance Extraction
extension UpdateExerciseSetStatsModel {
    private func milesOrMetres(from string: String) -> Double? {
        let lastTwo = string.suffix(2)
        let lastFive = string.suffix(5)
        if lastFive == milesSuffix {
            let milesString = string.dropLast(5)
            guard let miles = Double(milesString) else {return nil}
            return miles.convertMilesToKm()
        } else if lastTwo == kmSuffix {
            let kmString = string.dropLast(2)
            guard let km = Double(kmString) else {return nil}
            return km
        } else {
            let mString = string.dropLast(1)
            guard let m = Double(mString) else {return nil}
            return m / 1000
        }
    }
}
