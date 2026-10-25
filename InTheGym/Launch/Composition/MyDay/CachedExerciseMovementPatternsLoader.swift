//
//  CachedExerciseMovementPatternsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// The movement pattern twin of `CachedExerciseMuscleGroupsLoader`: cache
/// first with a refresh behind it, network only when the cache is empty, and
/// an empty result never cached. See that type for why.
final class CachedExerciseMovementPatternsLoader: ExerciseMovementPatternsLoader, @unchecked Sendable {
    private let remote: ExerciseMovementPatternsLoader
    private let cache: FileExerciseBodyListCache<ExerciseMovementPattern>

    init(remote: ExerciseMovementPatternsLoader, cache: FileExerciseBodyListCache<ExerciseMovementPattern>) {
        self.remote = remote
        self.cache = cache
    }

    func loadMovementPatterns() async throws -> [ExerciseMovementPattern] {
        if let cached = cache.load(), !cached.isEmpty {
            Task { _ = try? await refresh() }
            return cached
        }
        return try await refresh()
    }

    private func refresh() async throws -> [ExerciseMovementPattern] {
        let fresh = try await remote.loadMovementPatterns()
        if !fresh.isEmpty {
            cache.save(fresh)
        }
        return fresh
    }
}
