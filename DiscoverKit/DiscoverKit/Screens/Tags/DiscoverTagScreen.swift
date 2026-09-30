//
//  DiscoverTagScreen.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// Everything one tag is visible on: exercises, then public workouts, each
/// most-voted first and paging on its own.
struct DiscoverTagScreen: View {

    let tag: String
    @ObservedObject var exercises: DiscoverPager<DiscoverTagged<DiscoverExerciseCard>>
    @ObservedObject var workouts: DiscoverPager<DiscoverTagged<DiscoverWorkoutCard>>
    let onExerciseTapped: (DiscoverExerciseCard) -> Void
    let onWorkoutTapped: (DiscoverWorkoutCard) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                section("Exercises", pager: exercises) { tagged in
                    DiscoverExerciseRow(card: tagged.card)
                        .onTapGesture { onExerciseTapped(tagged.card) }
                }
                section("Workouts", pager: workouts) { tagged in
                    DiscoverWorkoutRow(card: tagged.card)
                        .onTapGesture { onWorkoutTapped(tagged.card) }
                }
            }
            .padding()
        }
        .background {
            Color.darkColor.ignoresSafeArea()
        }
        .navigationTitle("#\(tag)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            async let loadExercises: Void = exercises.loadFirstPageIfNeeded()
            async let loadWorkouts: Void = workouts.loadFirstPageIfNeeded()
            _ = await (loadExercises, loadWorkouts)
        }
    }

    private func section<Card, Row: View>(
        _ title: String,
        pager: DiscoverPager<Card>,
        @ViewBuilder row: @escaping (Card) -> Row
    ) -> some View {
        SectionContainer(title: title) {
            LazyVStack(spacing: 0) {
                ForEach(Array(pager.cards.enumerated()), id: \.element.id) { index, card in
                    if index > 0 {
                        Divider().padding(.leading, 72)
                    }
                    row(card)
                        .task { await pager.loadMore(ifShowing: card) }
                }
                if pager.didFail {
                    DiscoverSectionMessage(message: "Couldn't load \(title.lowercased())") {
                        Task { await pager.retry() }
                    }
                } else if pager.isLoading, pager.cards.isEmpty {
                    DiscoverRowSkeleton()
                    DiscoverRowSkeleton()
                } else if pager.isLoading {
                    ProgressView().padding(.vertical, 16)
                } else if pager.cards.isEmpty {
                    DiscoverSectionMessage(message: "No \(title.lowercased()) tagged #\(tag) yet")
                }
            }
        }
    }
}
