//
//  ExerciseLoader.swift
//  StatsKit
//
//  Created by Findlay Wood on 22/03/2026.
//

import Foundation

public protocol StatsKitExerciseLoader {
    func load() async throws -> [ExerciseStats]
}

struct MockExerciseLoader: StatsKitExerciseLoader {
    func load() async throws -> [ExerciseStats] {
        
        return ExerciseStats.mocks
    }
}
