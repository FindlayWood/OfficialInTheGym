//
//  UserProfileScreen.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import SwiftUI

/// Someone else's profile, pushed with the system bar from a follow list,
/// search, DISCOVER or a legacy screen. See `UserProfileViewModel`.
///
/// The Follow button is full width under the header: the one action on the
/// screen, at the size MyDay gives its primary actions. "Following" and
/// "Requested" are tinted rather than filled, as in the lists.
struct UserProfileScreen: View {

    @ObservedObject var viewModel: UserProfileViewModel
    @State private var confirmingUnfollow = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                switch viewModel.state {
                case .loading:
                    ProfileHeaderSkeleton()
                case .notFound:
                    notFound
                case .failed:
                    ProfileLoadFailedCard { Task { await viewModel.load() } }
                case .loaded(let profile):
                    ProfileHeaderCard(
                        header: profile.header,
                        photo: viewModel.photo,
                        stamps: viewModel.stamps,
                        counts: profile.counts,
                        onOpenFollowList: viewModel.canSeeActivity ? { viewModel.onOpenFollowList?($0) } : nil
                    )
                    if let message = viewModel.errorMessage {
                        ProfileErrorBanner(message: message)
                    }
                    if let status = viewModel.followStatus {
                        followButton(status)
                    }
                    if !viewModel.canSeeActivity {
                        privateCard
                    }
                    ProfileHighlightsSection(highlights: viewModel.highlights)
                    ProfileClipsSection(
                        clips: viewModel.clips,
                        clipCount: profile.clipCount,
                        isOwnProfile: false,
                        onOpenClip: { viewModel.onOpenClip?($0) }
                    )
                }
            }
            .padding(16)
        }
        .refreshable { await viewModel.load() }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle(viewModel.profile.map { "@\($0.header.username)" } ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .alert("Unfollow?", isPresented: $confirmingUnfollow) {
            Button("Unfollow", role: .destructive) { Task { await viewModel.toggleFollow() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This account is private. To follow again you'll need to send a new request.")
        }
    }

    private func followButton(_ status: FollowStatus) -> some View {
        Button {
            if viewModel.unfollowNeedsConfirmation {
                confirmingUnfollow = true
            } else {
                Task { await viewModel.toggleFollow() }
            }
        } label: {
            Text(title(for: status))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(status == .notFollowing ? Color.white : Color.darkColor)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(status == .notFollowing ? Color.darkColor : Color.darkColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isUpdatingFollow)
        .animation(.easeInOut(duration: 0.15), value: status)
    }

    private func title(for status: FollowStatus) -> String {
        switch status {
        case .notFollowing:
            viewModel.profile?.isPrivate == true ? "Request to Follow" : "Follow"
        case .requested:
            "Requested"
        case .following:
            "Following"
        }
    }

    private var privateCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text("This account is private")
                .font(.system(size: 16, weight: .semibold))
            Text(viewModel.followStatus == .requested
                 ? "Your request is waiting. You'll see their followers and lifts once they approve it."
                 : "Follow this account to see their followers and lifts.")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var notFound: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.slash")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text("This account isn't available")
                .font(.system(size: 16, weight: .semibold))
            Text("It may have been deleted.")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    NavigationStack {
        UserProfileScreen(
            viewModel: UserProfileViewModel(
                userId: "alex",
                currentUserId: "me",
                profileLoader: PreviewPublicProfileServices(isPrivate: true),
                photoLoader: PreviewProfilePhotoLoader(),
                statusLoader: PreviewFollowServices(),
                followWriter: PreviewFollowServices(),
                unfollower: PreviewFollowServices(),
                highlightsLoader: PreviewContentServices(),
                clipsLoader: PreviewContentServices()
            )
        )
    }
}
