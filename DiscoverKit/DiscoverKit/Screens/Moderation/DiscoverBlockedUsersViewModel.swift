//
//  DiscoverBlockedUsersViewModel.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Combine
import Foundation

/// The blocked users list: who they are, and unblocking. Names come from the
/// same cached profile loader comments use.
@MainActor
final class DiscoverBlockedUsersViewModel: ObservableObject {

    @Published private(set) var profiles: [String: DiscoverUserProfile] = [:]

    let moderation: DiscoverModerationStore
    private let profileLoader: UserProfileLoader

    init(moderation: DiscoverModerationStore, profileLoader: UserProfileLoader) {
        self.moderation = moderation
        self.profileLoader = profileLoader
    }

    var blockedUserIds: [String] {
        moderation.blockedUserIds.sorted { name(for: $0) < name(for: $1) }
    }

    func load() async {
        await moderation.loadIfNeeded()
        if let found = try? await profileLoader.profiles(for: moderation.blockedUserIds) {
            profiles = found
        }
    }

    func name(for userId: String) -> String {
        profiles[userId]?.name ?? "Deleted user"
    }

    func unblock(_ userId: String) async {
        await moderation.setBlocked(false, userId: userId)
    }
}
