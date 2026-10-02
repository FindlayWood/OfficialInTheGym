//
//  DiscoverBlockedUsersScreen.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// Everyone the user has blocked, with a way to undo each. Blocking is only
/// reversible if the blocked user can be found again — which is what this
/// screen is for.
struct DiscoverBlockedUsersScreen: View {

    @ObservedObject var viewModel: DiscoverBlockedUsersViewModel
    @ObservedObject var moderation: DiscoverModerationStore

    var body: some View {
        ScrollView {
            SectionContainer {
                if viewModel.blockedUserIds.isEmpty {
                    DiscoverSectionMessage(message: "You haven't blocked anyone.")
                } else {
                    VStack(spacing: 0) {
                        ForEach(viewModel.blockedUserIds, id: \.self) { userId in
                            if userId != viewModel.blockedUserIds.first {
                                Divider().padding(.leading, 58)
                            }
                            HStack(spacing: 12) {
                                DiscoverCommentAvatar(initial: viewModel.profiles[userId]?.initial)
                                Text(viewModel.name(for: userId))
                                    .font(.system(size: 15, weight: .semibold))
                                Spacer()
                                Button("Unblock") {
                                    Task { await viewModel.unblock(userId) }
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.darkColor)
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                }
            }
            .padding()
        }
        .background {
            Color.darkColor.ignoresSafeArea()
        }
        .navigationTitle("Blocked Users")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}
