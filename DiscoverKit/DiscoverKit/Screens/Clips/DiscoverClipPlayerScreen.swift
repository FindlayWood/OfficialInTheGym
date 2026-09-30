//
//  DiscoverClipPlayerScreen.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// One clip, full width and looping, with its exercise, a like and the way to
/// its comments beneath.
///
/// Black behind the video rather than `darkColor`: a video is framed by its
/// surroundings, and a brand colour around it tints how it looks.
struct DiscoverClipPlayerScreen: View {

    @ObservedObject var viewModel: DiscoverClipPlayerViewModel
    let onComments: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            video
                .aspectRatio(9.0 / 16.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
                .padding(.top, 8)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.card.exerciseName ?? "Clip")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                    if let uploadedAt = viewModel.card.uploadedAt {
                        Text(uploadedAt.discoverAge)
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                Spacer()
                DiscoverLikeButton(
                    isLiked: viewModel.isLiked,
                    count: viewModel.likeCount,
                    tint: .white
                ) {
                    Task { await viewModel.toggleLike() }
                }
                Button(action: onComments) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .font(.system(size: 14, weight: .semibold))
                        if let count = viewModel.card.commentCount, count > 0 {
                            Text("\(count)")
                                .font(.system(size: 13, weight: .medium))
                        }
                    }
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            Spacer(minLength: 0)
        }
        .background {
            Color.black.ignoresSafeArea()
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .onDisappear { viewModel.finishWatching() }
    }

    @ViewBuilder
    private var video: some View {
        if let url = viewModel.card.video {
            DiscoverLoopingPlayerView(
                url: url,
                onProgress: { viewModel.progressed(to: $0) },
                onLoop: { viewModel.looped($0) }
            )
        } else {
            ZStack {
                Color.darkColor
                Text("This clip can't be played")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}
