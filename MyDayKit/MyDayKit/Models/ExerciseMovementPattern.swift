//
//  ExerciseMovementPattern.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// One entry of the `MovementTypes` collection, as the custom exercise form
/// offers it: `push_horizontal` → "Push Horizontal".
///
/// As with `ExerciseMuscleGroup`, the id is what an exercise stores and `name`
/// is only ever shown.
public struct ExerciseMovementPattern: Codable, Hashable, Identifiable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
