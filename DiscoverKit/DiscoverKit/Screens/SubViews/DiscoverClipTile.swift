//
//  DiscoverClipTile.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI

/// A clip as a portrait thumbnail with its exercise and duration over the
/// bottom edge.
///
/// A missing thumbnail — generation can fail at upload — draws a `darkColor`
/// placeholder with a play glyph rather than an empty box, so the tile still
/// reads as a video.
struct DiscoverClipTile: View {
    let card: DiscoverClipCard
    /// Fixed width for the home strip; `nil` fills the proposed width, as a
    /// grid column does. The 11:16 portrait shape holds either way.
    var width: CGFloat? = 110

    var body: some View {
        Color.clear
            .aspectRatio(11.0 / 16.0, contentMode: .fit)
            .frame(width: width)
            .overlay { thumbnail }
            .overlay {
                LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom)
            }
            .overlay(alignment: .bottomLeading) { labels }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .contentShape(RoundedRectangle(cornerRadius: 14))
    }

    private var labels: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let name = card.exerciseName {
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
            }
            if let duration = card.formattedDuration {
                Text(duration)
                    .font(.system(size: 11, weight: .medium))
                    .opacity(0.8)
            }
        }
        .foregroundStyle(.white)
        .padding(8)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let url = card.thumbnail {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                placeholder
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            Color.darkColor
            Image(systemName: "play.fill")
                .font(.system(size: 20))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}
