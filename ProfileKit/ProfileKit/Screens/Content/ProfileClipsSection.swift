//
//  ProfileClipsSection.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import SwiftUI

/// The clips grid: three columns of portrait thumbnails, newest first, each
/// with its duration, as DISCOVER's clip grid draws them. Tapping one opens
/// DISCOVER's clip player, where liking, commenting and reporting already
/// live.
///
/// Public clips only, on your own profile too, because the profile is what
/// others see. An empty grid is drawn on your own profile, so you know where
/// clips will appear, and not drawn on someone else's.
struct ProfileClipsSection: View {

    let clips: [ProfileClip]
    let clipCount: Int?
    let isOwnProfile: Bool
    let onOpenClip: (ProfileClip) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)

    var body: some View {
        if isOwnProfile || !clips.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text("Clips")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .textCase(.uppercase)
                        .tracking(0.8)
                    if let clipCount, clipCount > 0 {
                        Text("\(clipCount)")
                            .font(.system(size: 13, weight: .semibold).monospacedDigit())
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                }
                .padding(.horizontal, 4)

                if clips.isEmpty {
                    Text("Clips you make public show here.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                } else {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(clips) { clip in
                            Button {
                                onOpenClip(clip)
                            } label: {
                                thumbnail(clip)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(clip.exerciseName.map { "Clip of \($0)" } ?? "Clip")
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
    }

    private func thumbnail(_ clip: ProfileClip) -> some View {
        Color(.tertiarySystemFill)
            .aspectRatio(9 / 16, contentMode: .fit)
            .overlay {
                AsyncImage(url: clip.thumbnail) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.secondary)
                }
            }
            .overlay(alignment: .bottomLeading) {
                if let duration = clip.formattedDuration {
                    Text(duration)
                        .font(.system(size: 11, weight: .semibold).monospacedDigit())
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.5), in: Capsule())
                        .padding(6)
                }
            }
            .clipped()
    }
}
