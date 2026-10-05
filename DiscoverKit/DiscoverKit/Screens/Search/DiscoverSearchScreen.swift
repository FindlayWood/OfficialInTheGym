//
//  DiscoverSearchScreen.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 05/10/2026.
//

import SwiftUI

/// Search, pushed from the magnifier on DISCOVER's title bar. The field and the
/// scope filter (`DiscoverSearchScopePicker`) sit on a white bar above a `darkColor` page of `SectionContainer` cards — People,
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
    let authors: DiscoverAuthorDirectory
    /// Nil with no profile opener: people still show, as plain rows.
    let onPersonTapped: ((DiscoverUserProfile) -> Void)?
    let onWorkoutTapped: (DiscoverWorkoutCard) -> Void
    let onExerciseTapped: (DiscoverExerciseCard) -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                DiscoverSearchField(text: $viewModel.query, isFocused: $isFocused)
                DiscoverSearchScopePicker(scope: $viewModel.scope)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                Color(.systemBackground).ignoresSafeArea()
            }
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.isIdle {
                        message(idleMessage)
                    } else if hasNoResults {
                        message("No results for \u{201C}\(viewModel.query.trimmingCharacters(in: .whitespaces))\u{201D}")
                    } else {
                        if viewModel.scope.includesPeople { peopleSection }
                        if viewModel.scope.includesWorkouts { workoutsSection }
                        if viewModel.scope.includesExercises { exercisesSection }
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

    /// Every kind in scope has answered, and answered with nothing.
    private var hasNoResults: Bool {
        let scope = viewModel.scope
        return (!scope.includesPeople || visiblePeople?.isEmpty == true)
            && (!scope.includesWorkouts || visibleWorkouts?.isEmpty == true)
            && (!scope.includesExercises || visibleExercises?.isEmpty == true)
    }

    private var idleMessage: String {
        switch viewModel.scope {
        case .all: "Search for people, workouts and exercises."
        case .people: "Search for people by name or @username."
        case .workouts: "Search for workouts by title."
        case .exercises: "Search for exercises by name."
        }
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
            dividerInset: 16,
            skeleton: AnyView(DiscoverWorkoutRowSkeleton()),
            retry: { await viewModel.retryWorkouts() }
        ) { workout in
            DiscoverWorkoutRow(card: workout, authors: authors)
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
        dividerInset: CGFloat = 72,
        skeleton: AnyView = AnyView(DiscoverRowSkeleton()),
        retry: @escaping () async -> Void,
        @ViewBuilder row: @escaping (Item) -> Row
    ) -> some View {
        switch state {
        case .loading:
            SectionContainer(title: title) {
                skeleton
                Divider().padding(.leading, dividerInset)
                skeleton
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
                                Divider().padding(.leading, dividerInset)
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
            authors: DiscoverAuthorDirectory(loader: PreviewUserProfileLoader(), currentUserId: "me"),
            onPersonTapped: { _ in },
            onWorkoutTapped: { _ in },
            onExerciseTapped: { _ in }
        )
    }
}
