//
//  MyDayLibraryProfileWorkoutsLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/11/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import MyDayKit
import ProfileKit

/// Answers ProfileKit's `ProfileLibraryLoader` from **MyDay's own library manager**, the instance
/// `MyDayKitComposition` builds (`MyDayWorkoutLibrary.manager`), so All workouts lists exactly
/// what MyDay's library does.
///
/// That manager reads the device first. A workout saved offline is therefore listed at once.
/// Reading Firestore here instead would hide it until it synced, the bug that once emptied
/// MyDay's library.
///
/// If the library has not loaded this session, this loads it and waits for it to settle. The
/// first `.loaded` is the device's copy, which is all a list needs; the network merge lands on the
/// next visit, since the screen reloads every time it appears. `.failed` is thrown, so the screen
/// can offer a retry, and `.empty` is an empty list.
struct MyDayLibraryProfileWorkoutsLoader: ProfileLibraryLoader {

    let manager: WorkoutLibraryManager

    func allWorkouts() async throws -> [ProfileWorkout] {
        switch await settledState() {
        case .loaded(let templates):
            return templates.map(Self.workout(from:))
        case .failed(let message):
            throw LibraryLoadError(message: message)
        case .empty, .loading:
            return []
        }
    }

    @MainActor
    private func settledState() async -> WorkoutLibraryState {
        if case .loaded = manager.state { return manager.state }
        manager.loadIfNeeded()
        for await state in manager.$state.values {
            if case .loading = state { continue }
            return state
        }
        return manager.state
    }

    private static func workout(from template: WorkoutTemplateModel) -> ProfileWorkout {
        ProfileWorkout(
            workoutId: template.id,
            title: template.title,
            createdBy: template.createdBy,
            exerciseCount: template.exercises.count,
            createdAt: template.createdAt,
            isPublic: template.isPublic,
            tags: template.tags
        )
    }

    struct LibraryLoadError: Error {
        let message: String
    }
}
