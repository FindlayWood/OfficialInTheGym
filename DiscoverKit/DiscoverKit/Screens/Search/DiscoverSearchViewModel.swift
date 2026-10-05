//
//  DiscoverSearchViewModel.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import Combine
import Foundation

/// DISCOVER's one search, over people, workouts and exercises. It replaced
/// ProfileKit's people-only search on the profile title bar, and carries that
/// search's three rules across:
///
/// - **The query is normalised once**, by `DiscoverSearchQuery`.
/// - **Debounced, and every keystroke cancels the search before it.** Without
///   cancelling, a slow early search ("a") can land after a fast later one
///   ("alex") and replace the right results with the wrong ones.
/// - **Results for a query no longer in the field are dropped**, checked as
///   each one lands, since cancellation does not stop a request already sent.
///
/// **Each kind loads and fails on its own**, as the home screen's sections do:
/// workouts failing is no reason to blank the people above them, and the
/// three are three separate queries that land at three different times. So
/// there is no single results state, only `isIdle` and one
/// `DiscoverSectionState` per kind.
@MainActor
final class DiscoverSearchViewModel: ObservableObject {

    /// Per kind. Three full lists of twenty would bury the third section.
    static let limit = 10

    @Published var query = "" {
        didSet { scheduleSearch() }
    }
    /// True while there is nothing to search for — the field is empty or only
    /// whitespace. The three states below are meaningless while it is.
    @Published private(set) var isIdle = true
    @Published private(set) var people: DiscoverSectionState<[DiscoverUserProfile]> = .loading
    @Published private(set) var workouts: DiscoverSectionState<[DiscoverWorkoutCard]> = .loading
    @Published private(set) var exercises: DiscoverSectionState<[DiscoverExerciseCard]> = .loading

    private let peopleLoader: PeopleSearchLoader
    private let workoutLoader: WorkoutSearchLoader
    private let exerciseLoader: ExerciseSearchLoader
    /// The signed-in user, left out of people results: DISCOVER never opens
    /// your own profile (see `DiscoverKitRouter.profileAction`), and a row
    /// that leads nowhere is worse than no row.
    private let currentUserId: String
    private let debounce: Duration
    private var searchTask: Task<Void, Never>?

    init(
        peopleLoader: PeopleSearchLoader,
        workoutLoader: WorkoutSearchLoader,
        exerciseLoader: ExerciseSearchLoader,
        currentUserId: String,
        debounce: Duration = .milliseconds(300)
    ) {
        self.peopleLoader = peopleLoader
        self.workoutLoader = workoutLoader
        self.exerciseLoader = exerciseLoader
        self.currentUserId = currentUserId
        self.debounce = debounce
    }

    private var normalizedQuery: String {
        DiscoverSearchQuery.normalized(query)
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        let text = normalizedQuery
        isIdle = text.isEmpty
        guard !text.isEmpty else { return }
        searchTask = Task { [weak self, debounce] in
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }
            await self?.search(text)
        }
    }

    /// Runs all three searches now, each publishing as it lands. The debounced
    /// path calls this; tests call it directly.
    func search(_ text: String) async {
        async let people: Void = searchPeople(text)
        async let workouts: Void = searchWorkouts(text)
        async let exercises: Void = searchExercises(text)
        _ = await (people, workouts, exercises)
    }

    // MARK: - Retry

    func retryPeople() async {
        guard !isIdle else { return }
        await searchPeople(normalizedQuery)
    }

    func retryWorkouts() async {
        guard !isIdle else { return }
        await searchWorkouts(normalizedQuery)
    }

    func retryExercises() async {
        guard !isIdle else { return }
        await searchExercises(normalizedQuery)
    }

    // MARK: - Kinds

    private func searchPeople(_ text: String) async {
        people = .loading
        do {
            let results = try await peopleLoader.people(matching: text, limit: Self.limit)
            guard isCurrent(text) else { return }
            people = .loaded(results.filter { $0.userId != currentUserId })
        } catch {
            guard isCurrent(text) else { return }
            print("❌ People search failed: \(error)")
            people = .failed
        }
    }

    private func searchWorkouts(_ text: String) async {
        workouts = .loading
        do {
            let results = try await workoutLoader.workouts(matching: text, limit: Self.limit)
            guard isCurrent(text) else { return }
            workouts = .loaded(results)
        } catch {
            guard isCurrent(text) else { return }
            print("❌ Workout search failed: \(error)")
            workouts = .failed
        }
    }

    private func searchExercises(_ text: String) async {
        exercises = .loading
        do {
            let results = try await exerciseLoader.exercises(matching: text, limit: Self.limit)
            guard isCurrent(text) else { return }
            exercises = .loaded(results)
        } catch {
            guard isCurrent(text) else { return }
            print("❌ Exercise search failed: \(error)")
            exercises = .failed
        }
    }

    private func isCurrent(_ text: String) -> Bool {
        !Task.isCancelled && normalizedQuery == text
    }
}
