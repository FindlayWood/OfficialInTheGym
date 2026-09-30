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
/// exercises. Tags join them once the tag directory exists.
struct DiscoverHomeScreen: View {

    @ObservedObject var viewModel: DiscoverHomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 24) {
                    clipsSection
                    workoutsSection
                    exercisesSection
                }
                .padding()
            }
            .refreshable { await viewModel.load() }
        }
        .background {
            Color.darkColor.ignoresSafeArea()
        }
        .task { await viewModel.load() }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Discover")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.darkColor)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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
            case .loaded(let clips) where clips.isEmpty:
                DiscoverSectionMessage(message: "No clips yet")
            case .loaded(let clips):
                clipStrip {
                    ForEach(clips) { clip in
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
                skeletonRows(count: 3)
            case .loaded(let workouts) where workouts.isEmpty:
                DiscoverSectionMessage(message: "No public workouts yet")
            case .loaded(let workouts):
                rows(workouts) { workout in
                    DiscoverWorkoutRow(card: workout)
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
                skeletonRows(count: 3)
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

    // MARK: - Rows

    private func rows<Card: Identifiable, Row: View>(
        _ cards: [Card],
        @ViewBuilder row: @escaping (Card) -> Row
    ) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                if index > 0 {
                    Divider().padding(.leading, 72)
                }
                row(card)
            }
        }
    }

    private func skeletonRows(count: Int) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<count, id: \.self) { index in
                if index > 0 {
                    Divider().padding(.leading, 72)
                }
                DiscoverRowSkeleton()
            }
        }
    }
}

#Preview {
    DiscoverHomeScreen(
        viewModel: DiscoverHomeViewModel(
            clipLoader: PreviewDiscoverClipCardLoader(),
            workoutLoader: PreviewDiscoverWorkoutCardLoader(),
            exerciseLoader: PreviewDiscoverExerciseCardLoader()
        )
    )
}
