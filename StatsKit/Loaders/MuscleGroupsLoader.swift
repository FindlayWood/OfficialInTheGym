//
//  MuscleGroupsLoader.swift
//  StatsKit
//
//  Created by Findlay Wood on 04/04/2026.
//

import Foundation

public protocol MuscleGroupsLoader {
    func loadAll() async throws -> [MuscleGroup]
}

class PreviewMuscleGroupsLoader: MuscleGroupsLoader {
    func loadAll() async throws -> [MuscleGroup] {
        return []
    }
}
