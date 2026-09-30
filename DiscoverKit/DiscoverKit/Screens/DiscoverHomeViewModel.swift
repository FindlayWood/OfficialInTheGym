//
//  DiscoverHomeViewModel.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Combine
import Foundation

/// The DISCOVER home: a short strip of each card type, newest first, each with
/// a way through to the full list, and the most-used tags.
///
/// The three sections load concurrently and independently — see
/// `DiscoverSectionState`. Navigation is raised through closures the router
/// fills; the view model knows nothing about where a tap leads.
@MainActor
final class DiscoverHomeViewModel: ObservableObject {

    @Published private(set) var clips: DiscoverSectionState<[DiscoverClipCard]> = .loading
    @Published private(set) var workouts: DiscoverSectionState<[DiscoverWorkoutCard]> = .loading
    @Published private(set) var exercises: DiscoverSectionState<[DiscoverExerciseCard]> = .loading
    @Published private(set) var tags: DiscoverSectionState<[DiscoverTag]> = .loading

    static let clipLimit = 10
    static let workoutLimit = 5
    static let exerciseLimit = 6
    static let tagLimit = 16

    private let clipLoader: DiscoverClipCardLoader
    private let workoutLoader: DiscoverWorkoutCardLoader
    private let exerciseLoader: DiscoverExerciseCardLoader
    private let tagLoader: PopularTagsLoader

    var onSeeAllClips: (() -> Void)?
    var onSeeAllWorkouts: (() -> Void)?
    var onSeeAllExercises: (() -> Void)?
    var onClipTapped: ((DiscoverClipCard) -> Void)?
    var onWorkoutTapped: ((DiscoverWorkoutCard) -> Void)?
    var onExerciseTapped: ((DiscoverExerciseCard) -> Void)?
    var onTagTapped: ((String) -> Void)?

    init(
        clipLoader: DiscoverClipCardLoader,
        workoutLoader: DiscoverWorkoutCardLoader,
        exerciseLoader: DiscoverExerciseCardLoader,
        tagLoader: PopularTagsLoader
    ) {
        self.clipLoader = clipLoader
        self.workoutLoader = workoutLoader
        self.exerciseLoader = exerciseLoader
        self.tagLoader = tagLoader
    }

    func load() async {
        async let clips: Void = loadClips()
        async let workouts: Void = loadWorkouts()
        async let exercises: Void = loadExercises()
        async let tags: Void = loadTags()
        _ = await (clips, workouts, exercises, tags)
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

    /// Tags on nothing yet are dropped: a tag document is never deleted, so
    /// one whose last subject went sits at zero rather than disappearing.
    func loadTags() async {
        tags = .loading
        do {
            let loaded = try await tagLoader.popularTags(limit: Self.tagLimit)
            tags = .loaded(loaded.filter { ($0.totalCount ?? 0) > 0 })
        } catch {
            print("❌ Discover tags failed: \(error)")
            tags = .failed
        }
    }
}
