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
    @ObservedObject var moderation: DiscoverModerationStore
    /// False on the user's own clip.
    let canReport: Bool
    let onComments: () -> Void
    /// Called after reporting or blocking — the player leaves, since what it
    /// shows is now hidden from this user.
    var onClose: () -> Void = {}
    /// The clip owner's profile. Nil when profiles cannot be opened, or for
    /// your own clip.
    var onOpenProfile: (() -> Void)?

    @State private var reportRequest: DiscoverReportRequest?
    @State private var isConfirmingBlock = false

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
        .toolbar {
            if canReport {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if let onOpenProfile {
                            Button("View profile", systemImage: "person.crop.circle", action: onOpenProfile)
                        }
                        Button("Report clip", systemImage: "flag") {
                            reportRequest = DiscoverReportRequest(target: .clip(id: viewModel.card.clipId))
                        }
                        if viewModel.card.createdBy != nil {
                            Button("Block user", systemImage: "hand.raised", role: .destructive) {
                                isConfirmingBlock = true
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(item: $reportRequest) { request in
            DiscoverReportSheet(target: request.target, moderation: moderation, onFinished: onClose)
                .presentationDetents([.medium])
        }
        .confirmationDialog("Block this user?", isPresented: $isConfirmingBlock, titleVisibility: .visible) {
            Button("Block", role: .destructive) {
                guard let userId = viewModel.card.createdBy else { return }
                Task {
                    if await moderation.setBlocked(true, userId: userId) { onClose() }
                }
            }
        } message: {
            Text("Their clips and comments will be hidden from you. They won't be told.")
        }
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
