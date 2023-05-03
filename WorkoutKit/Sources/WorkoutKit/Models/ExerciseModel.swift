//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/04/2023.
//

import Foundation

struct ExerciseModel: Codable, Identifiable {
    var id: String
    var name: String
    var workoutPosition: Int
    var type: ExerciseType
    var sets: [SetModel]
    var rpe: Int?
    var note: String?
}
extension ExerciseModel {
    static let example = ExerciseModel(id: UUID().uuidString, name: "Bench Press", workoutPosition: 0, type: .upperBody, sets: [.example])
}
extension ExerciseModel: Comparable {
    static func < (lhs: ExerciseModel, rhs: ExerciseModel) -> Bool {
        lhs.workoutPosition < rhs.workoutPosition
    }
}
