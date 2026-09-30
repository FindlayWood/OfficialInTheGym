//
//  DiscoverHomeViewModel.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Combine
import Foundation

/// The DISCOVER home: a short strip of each card type, newest first, each with
/// a way through to the full list.
///
/// The three sections load concurrently and independently — see
/// `DiscoverSectionState`. Navigation is raised through closures the router
/// fills; the view model knows nothing about where a tap leads.
@MainActor
final class DiscoverHomeViewModel: ObservableObject {

    @Published private(set) var clips: DiscoverSectionState<[DiscoverClipCard]> = .loading
    @Published private(set) var workouts: DiscoverSectionState<[DiscoverWorkoutCard]> = .loading
    @Published private(set) var exercises: DiscoverSectionState<[DiscoverExerciseCard]> = .loading

    static let clipLimit = 10
    static let workoutLimit = 5
    static let exerciseLimit = 6

    private let clipLoader: DiscoverClipCardLoader
    private let workoutLoader: DiscoverWorkoutCardLoader
    private let exerciseLoader: DiscoverExerciseCardLoader

    var onSeeAllClips: (() -> Void)?
    var onSeeAllWorkouts: (() -> Void)?
    var onSeeAllExercises: (() -> Void)?
    var onClipTapped: ((DiscoverClipCard) -> Void)?
    var onWorkoutTapped: ((DiscoverWorkoutCard) -> Void)?
    var onExerciseTapped: ((DiscoverExerciseCard) -> Void)?

    init(
        clipLoader: DiscoverClipCardLoader,
        workoutLoader: DiscoverWorkoutCardLoader,
        exerciseLoader: DiscoverExerciseCardLoader
    ) {
        self.clipLoader = clipLoader
        self.workoutLoader = workoutLoader
        self.exerciseLoader = exerciseLoader
    }

    func load() async {
        async let clips: Void = loadClips()
        async let workouts: Void = loadWorkouts()
        async let exercises: Void = loadExercises()
        _ = await (clips, workouts, exercises)
    }

    func loadClips() async {
        clips = .loading
        do {
            clips = .loaded(try await clipLoader.load(limit: Self.clipLimit, after: nil))
        } catch {
            print("❌ Discover clips failed: \(error)")
            clips = .failed
        }
    }

    func loadWorkouts() async {
        workouts = .loading
        do {
            workouts = .loaded(try await workoutLoader.load(limit: Self.workoutLimit, after: nil))
        } catch {
            print("❌ Discover workouts failed: \(error)")
            workouts = .failed
        }
    }

    func loadExercises() async {
        exercises = .loading
        do {
            exercises = .loaded(try await exerciseLoader.load(limit: Self.exerciseLimit, after: nil))
        } catch {
            print("❌ Discover exercises failed: \(error)")
            exercises = .failed
        }
    }
}
