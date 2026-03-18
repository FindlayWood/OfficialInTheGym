//
//  Exercise.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/08/2025.
//

import Foundation

public struct Exercise: Codable, Hashable {
    let id: String
    let name: String
    let category: ExerciseCategory
    
    static let pressUps = Exercise(id: UUID().uuidString, name: "Press Up", category: .upperBody)
    static let squat = Exercise(id: UUID().uuidString, name: "Squat", category: .lowerBody)
}
