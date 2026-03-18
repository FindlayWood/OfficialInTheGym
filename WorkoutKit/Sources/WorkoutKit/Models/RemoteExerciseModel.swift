//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/04/2023.
//

import Foundation

struct RemoteExerciseModel: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var workoutPosition: Int
    var type: ExerciseType
    var sets: [SetModel]
    var rpe: Int?
    var note: String?
}
extension RemoteExerciseModel {
    static let example = RemoteExerciseModel(name: "Bench Press", workoutPosition: 0, type: .upperBody, sets: [.example])
}
extension RemoteExerciseModel: Comparable {
    static func < (lhs: RemoteExerciseModel, rhs: RemoteExerciseModel) -> Bool {
        lhs.workoutPosition < rhs.workoutPosition
    }
}
