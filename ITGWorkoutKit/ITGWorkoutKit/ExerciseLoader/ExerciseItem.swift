//
//  ExerciseItem.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 25/05/2024.
//

import Foundation

public struct ExerciseItem: Hashable {
    let id: UUID
    let name: String
    let bodyArea: String
    
    public init(id: UUID, name: String, bodyArea: String) {
        self.id = id
        self.name = name
        self.bodyArea = bodyArea
    }
}
