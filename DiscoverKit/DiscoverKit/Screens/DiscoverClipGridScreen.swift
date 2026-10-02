//
//  DiscoverClipGridScreen.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI

/// Every public clip, three to a row, newest first — the "see all" for the
/// home screen's clip strip, paged by `DiscoverPager`.
struct DiscoverClipGridScreen: View {

    @ObservedObject var pager: DiscoverPager<DiscoverClipCard>
    @ObservedObject var moderation: DiscoverModerationStore
    let onTap: (DiscoverClipCard) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(pager.cards.filter { !moderation.hides($0) }) { clip in
                    DiscoverClipTile(card: clip, width: nil)
                        .onTapGesture { onTap(clip) }
                        .task { await pager.loadMore(ifShowing: clip) }
                }
            }
            .padding()

            footer
        }
        .background {
            Color.darkColor.ignoresSafeArea()
        }
        .navigationTitle("Clips")
        .navigationBarTitleDisplayMode(.inline)
        .task { await pager.loadFirstPageIfNeeded() }
    }

    @ViewBuilder
    private var footer: some View {
        if pager.didFail {
            SectionContainer {
                DiscoverSectionMessage(message: "Couldn't load clips") {
                    Task { await pager.retry() }
                }
            }
            .padding(.horizontal)
        } else if pager.isLoading {
            ProgressView().tint(.white).padding(.vertical, 16)
        } else if pager.cards.isEmpty {
            SectionContainer {
                DiscoverSectionMessage(message: "No clips yet")
            }
            .padding(.horizontal)
        }
    }
}
