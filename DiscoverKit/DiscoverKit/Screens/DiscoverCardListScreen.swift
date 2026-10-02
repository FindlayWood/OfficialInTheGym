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
/// Same `darkColor` page and `SectionContainer` card as the home screen, so
/// pushing from a section into its full list keeps the frame.
struct DiscoverCardListScreen<Card: Identifiable, Row: View>: View {

    let title: String
    let emptyMessage: String
    @ObservedObject var pager: DiscoverPager<Card>
    @ObservedObject var moderation: DiscoverModerationStore
    /// Whether this user has blocked or reported a card — it is skipped. The
    /// pager still pages over it, so "load more" keeps its place.
    var hides: (Card) -> Bool = { _ in false }
    let onTap: (Card) -> Void
    @ViewBuilder let row: (Card) -> Row

    var body: some View {
        ScrollView {
            SectionContainer {
                LazyVStack(spacing: 0) {
                    ForEach(Array(pager.cards.enumerated()), id: \.element.id) { index, card in
                        if hides(card) {
                            Color.clear.frame(height: 0)
                                .task { await pager.loadMore(ifShowing: card) }
                        } else {
                            if index > 0 {
                                Divider().padding(.leading, 72)
                            }
                            row(card)
                                .onTapGesture { onTap(card) }
                                .task { await pager.loadMore(ifShowing: card) }
                        }
                    }
                    footer
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
    private var footer: some View {
        if pager.didFail {
            DiscoverSectionMessage(message: "Couldn't load more") {
                Task { await pager.retry() }
            }
        } else if pager.isLoading {
            if pager.cards.isEmpty {
                DiscoverRowSkeleton()
                DiscoverRowSkeleton()
                DiscoverRowSkeleton()
            } else {
                ProgressView().padding(.vertical, 16)
            }
        } else if pager.cards.isEmpty {
            DiscoverSectionMessage(message: emptyMessage)
        }
    }
}
