//
//  DiscoverExerciseClipsSection.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 02/10/2026.
//

import SwiftUI

/// An exercise's clips as a horizontal strip — people doing the exercise,
/// which is the reason to look at clips from here. Clips by blocked users or
/// that the user reported are left out, as everywhere.
struct DiscoverExerciseClipsSection: View {

    @ObservedObject var viewModel: DiscoverExerciseClipsViewModel
    @ObservedObject var moderation: DiscoverModerationStore
    let onClipTapped: (DiscoverClipCard) -> Void

    var body: some View {
        SectionContainer(title: "Clips") {
            switch viewModel.clips {
            case .loading:
                strip {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.tertiarySystemFill))
                            .frame(width: 110, height: 160)
                    }
                }
            case .failed:
                DiscoverSectionMessage(message: "Couldn't load clips") {
                    Task { await viewModel.load() }
                }
            case .loaded(let clips):
                let shown = clips.filter { !moderation.hides($0) }
                if shown.isEmpty {
                    DiscoverSectionMessage(message: "No clips of this exercise yet")
                } else {
                    strip {
                        ForEach(shown) { clip in
                            DiscoverClipTile(card: clip)
                                .onTapGesture { onClipTapped(clip) }
                        }
                    }
                }
            }
        }
    }

    private func strip<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                content()
            }
            .padding(12)
        }
    }
}
