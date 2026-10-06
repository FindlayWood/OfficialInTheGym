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
    @ObservedObject var moderation: DiscoverModerationStore
    let authors: DiscoverAuthorDirectory
    let onExerciseTapped: (DiscoverExerciseCard) -> Void
    let onWorkoutTapped: (DiscoverWorkoutCard) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                section("Exercises", pager: exercises) { tagged in
                    DiscoverExerciseRow(card: tagged.card)
                        .onTapGesture { onExerciseTapped(tagged.card) }
                }
                section(
                    "Workouts",
                    pager: workouts,
                    hides: { moderation.hides($0.card) },
                    separatesCards: true,
                    skeleton: AnyView(DiscoverWorkoutRowSkeleton())
                ) { tagged in
                    DiscoverWorkoutRow(card: tagged.card, authors: authors)
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

    /// A hidden card is skipped without a row or a divider — it still takes
    /// part in paging, so reaching it loads the next page as its row would have.
    ///
    /// Exercises join inside one `SectionContainer`; workouts (`separatesCards`)
    /// stand as cards of their own, as everywhere — see `DiscoverWorkoutRow`.
    @ViewBuilder
    private func section<Card, Row: View>(
        _ title: String,
        pager: DiscoverPager<Card>,
        hides: @escaping (Card) -> Bool = { _ in false },
        separatesCards: Bool = false,
        skeleton: AnyView = AnyView(DiscoverRowSkeleton()),
        @ViewBuilder row: @escaping (Card) -> Row
    ) -> some View {
        let content = sectionContent(
            title,
            pager: pager,
            hides: hides,
            separatesCards: separatesCards,
            skeleton: skeleton,
            row: row
        )
        if separatesCards {
            DiscoverSeparateCardsSection(title: title) { content }
        } else {
            SectionContainer(title: title) {
                LazyVStack(spacing: 0) { content }
            }
        }
    }

    @ViewBuilder
    private func sectionContent<Card, Row: View>(
        _ title: String,
        pager: DiscoverPager<Card>,
        hides: @escaping (Card) -> Bool,
        separatesCards: Bool,
        skeleton: AnyView,
        @ViewBuilder row: @escaping (Card) -> Row
    ) -> some View {
        let shownIds = Set(pager.cards.filter { !hides($0) }.map(\.id))
        ForEach(pager.cards) { card in
            if shownIds.contains(card.id) {
                if !separatesCards, card.id != pager.cards.first(where: { shownIds.contains($0.id) })?.id {
                    Divider().padding(.leading, 72)
                }
                row(card)
                    .task { await pager.loadMore(ifShowing: card) }
            } else {
                Color.clear.frame(height: 0)
                    .task { await pager.loadMore(ifShowing: card) }
            }
        }
        if pager.didFail {
            message(DiscoverSectionMessage(message: "Couldn't load \(title.lowercased())") {
                Task { await pager.retry() }
            }, separatesCards: separatesCards)
        } else if pager.isLoading, pager.cards.isEmpty {
            skeleton
            skeleton
        } else if pager.isLoading {
            ProgressView()
                .tint(separatesCards ? .white : nil)
                .padding(.vertical, 16)
        } else if pager.cards.allSatisfy(hides) {
            message(
                DiscoverSectionMessage(message: "No \(title.lowercased()) tagged #\(tag) yet"),
                separatesCards: separatesCards
            )
        }
    }

    /// A message standing in for separate cards needs a card of its own.
    @ViewBuilder
    private func message(_ message: DiscoverSectionMessage, separatesCards: Bool) -> some View {
        if separatesCards {
            message.discoverCardChrome()
        } else {
            message
        }
    }
}
