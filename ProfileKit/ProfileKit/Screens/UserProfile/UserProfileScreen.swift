//
//  UserProfileScreen.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import SwiftUI

/// Someone else's profile, pushed with the system bar from a follow list,
/// DISCOVER (its search included) or a legacy screen. See `UserProfileViewModel`.
///
/// The Follow button is full width under the header: the one action on the
/// screen, at the size MyDay gives its primary actions. "Following" and
/// "Requested" are tinted rather than filled, as in the lists.
struct UserProfileScreen: View {

    @ObservedObject var viewModel: UserProfileViewModel
    @State private var confirmingUnfollow = false
    @State private var confirmingBlock = false
    @State private var isReporting = false

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
                    if viewModel.isBlocked == true {
                        blockedCard
                    } else {
                        if let status = viewModel.followStatus {
                            followButton(status)
                        }
                        if !viewModel.canSeeActivity {
                            privateCard
                        }
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
        .toolbar {
            if !viewModel.isOwnProfile, viewModel.profile != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Report Profile", systemImage: "flag") { isReporting = true }
                        if viewModel.isBlocked == true {
                            Button("Unblock", systemImage: "hand.raised.slash") {
                                Task { await viewModel.setBlocked(false) }
                            }
                        } else {
                            Button("Block", systemImage: "hand.raised", role: .destructive) { confirmingBlock = true }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("More options")
                }
            }
        }
        .sheet(isPresented: $isReporting) {
            ProfileReportSheet(displayName: viewModel.profile?.header.displayName ?? "this person") { reason in
                await viewModel.report(reason)
            }
            .presentationDetents([.medium, .large])
        }
        .alert("Block \(viewModel.profile?.header.displayName ?? "this person")?", isPresented: $confirmingBlock) {
            Button("Block", role: .destructive) { Task { await viewModel.setBlocked(true) } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You'll stop following each other, and neither of you can follow the other. Their comments and clips are hidden from you in Discover. They won't be told.")
        }
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

    private var blockedCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text("You've blocked this account")
                .font(.system(size: 16, weight: .semibold))
            Text("Unblock to see their profile again. Follows that ended with the block aren't restored.")
                .font(.system(size: 14))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
            Button {
                Task { await viewModel.setBlocked(false) }
            } label: {
                Text("Unblock")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                    .padding(.horizontal, 20)
                    .frame(height: 40)
                    .background(Color.darkColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isUpdatingBlock)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
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
                clipsLoader: PreviewContentServices(),
                reporter: PreviewModerationServices(),
                blocker: PreviewModerationServices(),
                blockStatusLoader: PreviewModerationServices()
            )
        )
    }
}
