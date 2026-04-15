//
//  MovementTypesLoader.swift
//  StatsKit
//
//  Created by Findlay Wood on 13/04/2026.
//

import Foundation

public protocol MovementTypesLoader {
    func loadAll() async throws -> [MovementPattern]
}

class PreviewMovementTypesLoader: MovementTypesLoader {
    func loadAll() async throws -> [MovementPattern] {
        return []
    }
}
