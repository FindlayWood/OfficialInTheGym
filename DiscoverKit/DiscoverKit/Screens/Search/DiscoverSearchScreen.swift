//
//  DiscoverSearchScreen.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import SwiftUI

/// Search, pushed from the magnifier on DISCOVER's title bar. The field sits
/// on a white bar above a `darkColor` page of `SectionContainer` cards — People,
/// Workouts, Exercises — so results read like the home screen's sections.
///
/// **A kind with no matches is left out rather than drawn as an empty card**;
/// three "No results" cards would bury the one that has some. Only when every
/// kind has answered with nothing is there a single "No results" message.
/// Loading and failure are always drawn, per kind, since neither is an answer.
///
/// Moderation filters here, as on every other DISCOVER list: blocked people,
/// and workouts the user blocked or reported, never appear.
struct DiscoverSearchScreen: View {

    @ObservedObject var viewModel: DiscoverSearchViewModel
    @ObservedObject var moderation: DiscoverModerationStore
    /// Nil with no profile opener: people still show, as plain rows.
    let onPersonTapped: ((DiscoverUserProfile) -> Void)?
    let onWorkoutTapped: (DiscoverWorkoutCard) -> Void
    let onExerciseTapped: (DiscoverExerciseCard) -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            DiscoverSearchField(text: $viewModel.query, isFocused: $isFocused)
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.isIdle {
                        message("Search for people, workouts and exercises.")
                    } else if hasNoResults {
                        message("No results for \u{201C}\(viewModel.query.trimmingCharacters(in: .whitespaces))\u{201D}")
                    } else {
                        peopleSection
                        workoutsSection
                        exercisesSection
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background {
            Color.darkColor.ignoresSafeArea()
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { isFocused = true }
        .task { await moderation.loadIfNeeded() }
    }

    // MARK: - Filtering

    private var visiblePeople: [DiscoverUserProfile]? {
        guard case .loaded(let people) = viewModel.people else { return nil }
        return people.filter { !moderation.isBlocked($0.userId) }
    }

    private var visibleWorkouts: [DiscoverWorkoutCard]? {
        guard case .loaded(let workouts) = viewModel.workouts else { return nil }
        return workouts.filter { !moderation.hides($0) }
    }

    private var visibleExercises: [DiscoverExerciseCard]? {
        guard case .loaded(let exercises) = viewModel.exercises else { return nil }
        return exercises
    }

    /// Every kind has answered, and answered with nothing.
    private var hasNoResults: Bool {
        visiblePeople?.isEmpty == true
            && visibleWorkouts?.isEmpty == true
            && visibleExercises?.isEmpty == true
    }

    // MARK: - Sections

    @ViewBuilder
    private var peopleSection: some View {
        section(
            title: "People",
            state: viewModel.people,
            visible: visiblePeople,
            failure: "Couldn't search people",
            retry: { await viewModel.retryPeople() }
        ) { person in
            DiscoverPersonRow(person: person, isTappable: onPersonTapped != nil)
                .onTapGesture { onPersonTapped?(person) }
        }
    }

    @ViewBuilder
    private var workoutsSection: some View {
        section(
            title: "Workouts",
            state: viewModel.workouts,
            visible: visibleWorkouts,
            failure: "Couldn't search workouts",
            retry: { await viewModel.retryWorkouts() }
        ) { workout in
            DiscoverWorkoutRow(card: workout)
                .onTapGesture { onWorkoutTapped(workout) }
        }
    }

    @ViewBuilder
    private var exercisesSection: some View {
        section(
            title: "Exercises",
            state: viewModel.exercises,
            visible: visibleExercises,
            failure: "Couldn't search exercises",
            retry: { await viewModel.retryExercises() }
        ) { exercise in
            DiscoverExerciseRow(card: exercise)
                .onTapGesture { onExerciseTapped(exercise) }
        }
    }

    /// One kind's card. `visible` is the loaded results after moderation, nil
    /// while loading or failed; an empty one draws nothing at all.
    @ViewBuilder
    private func section<Item: Identifiable, Row: View>(
        title: String,
        state: DiscoverSectionState<[Item]>,
        visible: [Item]?,
        failure: String,
        retry: @escaping () async -> Void,
        @ViewBuilder row: @escaping (Item) -> Row
    ) -> some View {
        switch state {
        case .loading:
            SectionContainer(title: title) {
                DiscoverRowSkeleton()
                Divider().padding(.leading, 72)
                DiscoverRowSkeleton()
            }
        case .failed:
            SectionContainer(title: title) {
                DiscoverSectionMessage(message: failure) {
                    Task { await retry() }
                }
            }
        case .loaded:
            if let visible, !visible.isEmpty {
                SectionContainer(title: title) {
                    VStack(spacing: 0) {
                        ForEach(Array(visible.enumerated()), id: \.element.id) { index, item in
                            if index > 0 {
                                Divider().padding(.leading, 72)
                            }
                            row(item)
                        }
                    }
                }
            }
        }
    }

    private func message(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15))
            .foregroundStyle(.white.opacity(0.75))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
    }
}

#Preview {
    let loaders = PreviewSearchLoaders()
    let viewModel = DiscoverSearchViewModel(
        peopleLoader: loaders,
        workoutLoader: loaders,
        exerciseLoader: loaders,
        currentUserId: "me"
    )
    viewModel.query = "p"
    return NavigationStack {
        DiscoverSearchScreen(
            viewModel: viewModel,
            moderation: PreviewModeration.store(),
            onPersonTapped: { _ in },
            onWorkoutTapped: { _ in },
            onExerciseTapped: { _ in }
        )
    }
}
