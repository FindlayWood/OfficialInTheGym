//
//  Circuit.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

struct CircuitModel: ExerciseType, Codable, Hashable {
    var id: String = UUID().uuidString
    var circuitPosition: Int
    var workoutPosition: Int
    var exercises: [ExerciseModel]
    var completed: Bool
    var circuitName: String
    var createdBy: String
    var creatorID: String
    var savedID: String?
    var integrated: Bool
    var startTime: TimeInterval?
    var rpe: Int?
    
    func intergrate() -> [CircuitTableModel] {
        var circuitModels = [CircuitTableModel]()
        let originalSets = exercises.map { $0.sets }
        var sets = exercises.map { $0.sets }
        while sets.reduce(0, +) > 0 {
            for i in 0..<sets.count {
                let set = originalSets[i] - sets[i]
                circuitModels.append(CircuitTableModel(exerciseName: exercises[i].exercise,
                                                       reps: exercises[i].reps?[set] ?? 0,
                                                       weight: exercises[i].weight?[set] ?? "",
                                                     set: set + 1,
                                                     overallSet: circuitModels.count + 1,
                                                       completed: exercises[i].completedSets?[set] ?? false,
                                                     exerciseOrder: i))
                sets[i] -= 1
            }
        }
        return circuitModels
    }
}
// MARK: - Circuit Database Models
struct CircuitDatabaseModel {
    var circuitModel: CircuitModel
    var workoutModel: WorkoutModel
}
extension CircuitDatabaseModel {
    func getCompletedSetPoint(exercisePosition: Int, setNumber: Int) -> FirebaseMultiUploadDataPoint {
        let path = "Workouts/\(UserDefaults.currentUser.uid)/\(workoutModel.id)/circuits/\(circuitModel.circuitPosition)/exercises/\(exercisePosition)/completedSets/\(setNumber)"
        return FirebaseMultiUploadDataPoint(value: true, path: path)
    }
    func getCompletedCircuitPoints(rpe: Int) -> [FirebaseMultiUploadDataPoint] {
        let scorePath = "Workouts/\(UserDefaults.currentUser.uid)/\(workoutModel.id)/circuits/\(circuitModel.circuitPosition)/score"
        let completedPath = "Workouts/\(UserDefaults.currentUser.uid)/\(workoutModel.id)/circuits/\(circuitModel.circuitPosition)/completed"
        return [FirebaseMultiUploadDataPoint(value: rpe, path: scorePath), FirebaseMultiUploadDataPoint(value: true, path: completedPath)]
    }
}
