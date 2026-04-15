//
//  Exercise.swift
//  StatsKit
//
//  Created by Findlay Wood on 04/04/2026.
//

import Foundation

public struct Exercise: Codable, Hashable {
    let id: String
    let name: String
    let category: ExerciseCategory
    
    static let pressUps = Exercise(id: UUID().uuidString, name: "Press Up", category: .upperBody)
    static let squat = Exercise(id: UUID().uuidString, name: "Squat", category: .lowerBody)
}
