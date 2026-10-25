//
//  CachedExerciseMuscleGroupsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 25/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// Answers from the disk cache when it has the list, refreshing it from the
/// network behind the answer; goes to the network only when it has nothing.
///
/// **The form must work offline.** A custom exercise is saved locally first so
/// it can be made with no signal (`CUSTOM_EXERCISES_PLAN.md` step 4), and it
/// cannot be saved without at least one muscle group — so a form whose chips
/// needed the network would block exactly the case local-first saving exists
/// for. The list rarely changes, so a copy one visit stale is fine.
///
/// **An empty result never replaces the cache.** Offline, a Firestore read can
/// come back empty rather than failing, and caching that would leave the form
/// with no chips until the next good read.
final class CachedExerciseMuscleGroupsLoader: ExerciseMuscleGroupsLoader, @unchecked Sendable {
    private let remote: ExerciseMuscleGroupsLoader
    private let cache: FileExerciseBodyListCache<ExerciseMuscleGroup>

    init(remote: ExerciseMuscleGroupsLoader, cache: FileExerciseBodyListCache<ExerciseMuscleGroup>) {
        self.remote = remote
        self.cache = cache
    }

    func loadMuscleGroups() async throws -> [ExerciseMuscleGroup] {
        if let cached = cache.load(), !cached.isEmpty {
            Task { _ = try? await refresh() }
            return cached
        }
        return try await refresh()
    }

    private func refresh() async throws -> [ExerciseMuscleGroup] {
        let fresh = try await remote.loadMuscleGroups()
        if !fresh.isEmpty {
            cache.save(fresh)
        }
        return fresh
    }
}
