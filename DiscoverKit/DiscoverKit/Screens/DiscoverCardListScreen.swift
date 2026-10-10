//
//  DiscoverCardListScreen.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI

/// A "see all" list of one card type, paged by `DiscoverPager`. Shared by the
/// workout and exercise lists, which differ only in their row — one screen
/// rather than two copies that would drift.
///
/// Same `darkColor` page as the home screen, and the same layout as the
/// section it came from, so pushing into the full list keeps the frame:
/// exercises as rows joined inside one `SectionContainer` card, workouts as
/// separate cards (`separatesCards`, see `DiscoverWorkoutRow`).
struct DiscoverCardListScreen<Card: Identifiable, Row: View>: View {

    let title: String
    let emptyMessage: String
    @ObservedObject var pager: DiscoverPager<Card>
    @ObservedObject var moderation: DiscoverModerationStore
    /// Whether this user has blocked or reported a card — it is skipped. The
    /// pager still pages over it, so "load more" keeps its place.
    var hides: (Card) -> Bool = { _ in false }
    /// Each card stands apart, with its own chrome, instead of joining the
    /// others inside one card. The rows passed in must draw that chrome.
    var separatesCards = false
    /// Loading rows shaped like the real one.
    var skeleton: AnyView = AnyView(DiscoverRowSkeleton())
    let onTap: (Card) -> Void
    @ViewBuilder let row: (Card) -> Row

    var body: some View {
        ScrollView {
            Group {
                if separatesCards {
                    LazyVStack(spacing: 10) { list }
                } else {
                    SectionContainer {
                        LazyVStack(spacing: 0) { list }
                    }
                }
            }
            .padding()
        }
        .background {
            Color.darkColor.ignoresSafeArea()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await pager.loadFirstPageIfNeeded() }
    }

    @ViewBuilder
    private var list: some View {
        ForEach(Array(pager.cards.enumerated()), id: \.element.id) { index, card in
            if hides(card) {
                Color.clear.frame(height: 0)
                    .task { await pager.loadMore(ifShowing: card) }
            } else {
                if index > 0, !separatesCards {
                    Divider().padding(.leading, 72)
                }
                row(card)
                    .onTapGesture { onTap(card) }
                    .task { await pager.loadMore(ifShowing: card) }
            }
        }
        footer
    }

    @ViewBuilder
    private var footer: some View {
        if pager.didFail {
            message(DiscoverSectionMessage(message: "Couldn't load more") {
                Task { await pager.retry() }
            })
        } else if pager.isLoading {
            if pager.cards.isEmpty {
                ForEach(0..<3, id: \.self) { index in
                    if index > 0, !separatesCards {
                        Divider().padding(.leading, 72)
                    }
                    skeleton
                }
            } else {
                ProgressView()
                    .tint(separatesCards ? .white : nil)
                    .padding(.vertical, 16)
            }
        } else if pager.cards.isEmpty {
            message(DiscoverSectionMessage(message: emptyMessage))
        }
    }

    /// A message standing in for cards needs a card of its own when there is
    /// no surrounding `SectionContainer` to sit in.
    @ViewBuilder
    private func message(_ message: DiscoverSectionMessage) -> some View {
        if separatesCards {
            message.discoverCardChrome()
        } else {
            message
        }
    }
}
