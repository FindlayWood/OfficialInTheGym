//
//  DiscoverHomeScreen.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI

/// The DISCOVER tab root. Same frame as the STATS tab — white title bar over a
/// `darkColor` page of `SectionContainer` cards — so switching between the two
/// does not change what the app looks like.
///
/// Sections, in order: clips (the only visual content, so it leads), workouts,
/// exercises, then the most-used tags.
struct DiscoverHomeScreen: View {

    @ObservedObject var viewModel: DiscoverHomeViewModel
    @ObservedObject var moderation: DiscoverModerationStore
    let authors: DiscoverAuthorDirectory

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 24) {
                    clipsSection
                    workoutsSection
                    exercisesSection
                    tagsSection
                }
                .padding()
            }
            .refreshable { await viewModel.load() }
        }
        .background {
            Color.darkColor.ignoresSafeArea()
        }
        .task {
            async let content: Void = viewModel.load()
            async let moderationState: Void = moderation.loadIfNeeded()
            _ = await (content, moderationState)
        }
    }

    // MARK: - Header

    /// The magnifier is the app's one search — people, workouts and exercises.
    /// It used to be people only, on the profile's title bar.
    private var header: some View {
        HStack {
            Text("Discover")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.darkColor)
            Spacer()
            Button {
                viewModel.onOpenSearch?()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Search")
        }
        .padding(.leading, 16)
        .padding(.trailing, 6)
        .padding(.vertical, 6)
        .background {
            Color(.systemBackground).ignoresSafeArea()
        }
    }

    // MARK: - Clips

    private var clipsSection: some View {
        SectionContainer(
            title: "Clips",
            headerTrailing: AnyView(SeeAllButton { viewModel.onSeeAllClips?() })
        ) {
            switch viewModel.clips {
            case .loading:
                clipStrip {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.tertiarySystemFill))
                            .frame(width: 110, height: 160)
                    }
                }
            case .loaded(let clips) where clips.allSatisfy(moderation.hides):
                DiscoverSectionMessage(message: "No clips yet")
            case .loaded(let clips):
                clipStrip {
                    ForEach(clips.filter { !moderation.hides($0) }) { clip in
                        DiscoverClipTile(card: clip)
                            .onTapGesture { viewModel.onClipTapped?(clip) }
                    }
                }
            case .failed:
                DiscoverSectionMessage(message: "Couldn't load clips") {
                    Task { await viewModel.loadClips() }
                }
            }
        }
    }

    private func clipStrip<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                content()
            }
            .padding(12)
        }
    }

    // MARK: - Workouts

    private var workoutsSection: some View {
        SectionContainer(
            title: "Workouts",
            headerTrailing: AnyView(SeeAllButton { viewModel.onSeeAllWorkouts?() })
        ) {
            switch viewModel.workouts {
            case .loading:
                skeletonRows(count: 3, dividerInset: 16) { DiscoverWorkoutRowSkeleton() }
            case .loaded(let workouts) where workouts.allSatisfy(moderation.hides):
                DiscoverSectionMessage(message: "No public workouts yet")
            case .loaded(let workouts):
                rows(workouts.filter { !moderation.hides($0) }, dividerInset: 16) { workout in
                    DiscoverWorkoutRow(card: workout, authors: authors)
                        .onTapGesture { viewModel.onWorkoutTapped?(workout) }
                }
            case .failed:
                DiscoverSectionMessage(message: "Couldn't load workouts") {
                    Task { await viewModel.loadWorkouts() }
                }
            }
        }
    }

    // MARK: - Exercises

    private var exercisesSection: some View {
        SectionContainer(
            title: "Exercises",
            headerTrailing: AnyView(SeeAllButton { viewModel.onSeeAllExercises?() })
        ) {
            switch viewModel.exercises {
            case .loading:
                skeletonRows(count: 3) { DiscoverRowSkeleton() }
            case .loaded(let exercises) where exercises.isEmpty:
                DiscoverSectionMessage(message: "No exercises yet")
            case .loaded(let exercises):
                rows(exercises) { exercise in
                    DiscoverExerciseRow(card: exercise)
                        .onTapGesture { viewModel.onExerciseTapped?(exercise) }
                }
            case .failed:
                DiscoverSectionMessage(message: "Couldn't load exercises") {
                    Task { await viewModel.loadExercises() }
                }
            }
        }
    }

    // MARK: - Tags

    private var tagsSection: some View {
        SectionContainer(title: "Tags") {
            switch viewModel.tags {
            case .loading:
                DiscoverFlowLayout {
                    ForEach(0..<6, id: \.self) { _ in
                        Capsule().fill(Color(.tertiarySystemFill)).frame(width: 70, height: 32)
                    }
                }
                .padding(16)
            case .loaded(let tags) where tags.allSatisfy({ moderation.hides(tag: $0.tag) }):
                DiscoverSectionMessage(message: "No tags yet")
            case .loaded(let tags):
                DiscoverFlowLayout {
                    ForEach(tags.filter { !moderation.hides(tag: $0.tag) }) { tag in
                        DiscoverTagChip(tag: tag.tag, count: tag.totalCount)
                            .onTapGesture { viewModel.onTagTapped?(tag.tag) }
                    }
                }
                .padding(16)
            case .failed:
                DiscoverSectionMessage(message: "Couldn't load tags") {
                    Task { await viewModel.loadTags() }
                }
            }
        }
    }

    // MARK: - Rows

    /// `dividerInset` lines the divider up with the row's text: 72 past an
    /// icon tile, 16 for workout rows, which have none.
    private func rows<Card: Identifiable, Row: View>(
        _ cards: [Card],
        dividerInset: CGFloat = 72,
        @ViewBuilder row: @escaping (Card) -> Row
    ) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                if index > 0 {
                    Divider().padding(.leading, dividerInset)
                }
                row(card)
            }
        }
    }

    private func skeletonRows<Skeleton: View>(
        count: Int,
        dividerInset: CGFloat = 72,
        @ViewBuilder skeleton: @escaping () -> Skeleton
    ) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<count, id: \.self) { index in
                if index > 0 {
                    Divider().padding(.leading, dividerInset)
                }
                skeleton()
            }
        }
    }
}

#Preview {
    DiscoverHomeScreen(
        viewModel: DiscoverHomeViewModel(
            clipLoader: PreviewDiscoverClipCardLoader(),
            workoutLoader: PreviewDiscoverWorkoutCardLoader(),
            exerciseLoader: PreviewDiscoverExerciseCardLoader(),
            tagLoader: PreviewTagLoaders()
        ),
        moderation: PreviewModeration.store(),
        authors: DiscoverAuthorDirectory(loader: PreviewUserProfileLoader(), currentUserId: "me")
    )
}
