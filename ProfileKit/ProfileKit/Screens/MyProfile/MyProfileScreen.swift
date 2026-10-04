//
//  MyProfileScreen.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import SwiftUI

/// The PROFILE tab root: the signed-in user's own profile.
///
/// It draws its own title bar ("Profile" and a settings gear), as the DISCOVER
/// and STATS roots do, and `ProfileKitBoundaryViewController` hides the system
/// bar around it. The gear replaces the legacy "More" menu: everything that menu
/// still had to offer now lives in settings.
///
/// The page is `systemBackground` with `secondarySystemBackground` cards, MyDay's
/// vocabulary and the one onboarding uses (`PROFILE_PLAN.md`, *Design*).
struct MyProfileScreen: View {

    @ObservedObject var viewModel: MyProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    if viewModel.pendingRequestCount > 0 {
                        FollowRequestsBanner(count: viewModel.pendingRequestCount) {
                            viewModel.onOpenFollowRequests?()
                        }
                    }
                    if case .loaded = viewModel.header {
                        ProfileHighlightsSection(highlights: viewModel.highlights) {
                            viewModel.editHighlights()
                        }
                        ProfileClipsSection(
                            clips: viewModel.clips,
                            clipCount: viewModel.publicProfile?.clipCount,
                            isOwnProfile: true,
                            onOpenClip: { viewModel.onOpenClip?($0) }
                        )
                    }
                }
                .padding(16)
            }
            .refreshable { await viewModel.load() }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .task { await viewModel.load() }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Text("Profile")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.darkColor)
            Spacer()
            Button {
                viewModel.onOpenSearch?()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Find people")
            Button {
                viewModel.onOpenSettings?()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.darkColor)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Settings")
        }
        .padding(.leading, 16)
        .padding(.trailing, 6)
        .padding(.vertical, 6)
    }

    // MARK: - Header

    @ViewBuilder
    private var headerSection: some View {
        switch viewModel.header {
        case .loading:
            ProfileHeaderSkeleton()
        case .loaded(let header):
            ProfileHeaderCard(
                header: header,
                photo: viewModel.photo,
                stamps: viewModel.stamps,
                onEdit: { viewModel.editProfile() },
                counts: viewModel.counts,
                onOpenFollowList: { viewModel.onOpenFollowList?($0) }
            )
        case .failed:
            ProfileLoadFailedCard {
                Task { await viewModel.load() }
            }
        }
    }
}

#Preview {
    MyProfileScreen(
        viewModel: MyProfileViewModel(
            profileLoader: PreviewMyProfileLoader(),
            photoLoader: PreviewProfilePhotoLoader(),
            publicProfileLoader: PreviewPublicProfileServices(),
            requestCountLoader: PreviewPrivacyServices(),
            highlightsLoader: PreviewContentServices(),
            clipsLoader: PreviewContentServices(),
            subscription: PreviewProfileSubscriptionService(hasUnlockedPro: true)
        )
    )
}
