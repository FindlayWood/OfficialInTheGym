//
//  PreviewUserProfileLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Preview conformer with three users; any other id is a deleted account.
public final class PreviewUserProfileLoader: UserProfileLoader, @unchecked Sendable {
    public init() {}

    public func profiles(for userIds: Set<String>) async throws -> [String: DiscoverUserProfile] {
        Self.profiles.filter { userIds.contains($0.key) }
    }

    static let profiles: [String: DiscoverUserProfile] = [
        "u1": DiscoverUserProfile(userId: "u1", username: "findlay", displayName: "Findlay"),
        "u2": DiscoverUserProfile(userId: "u2", username: "sam", displayName: "Sam"),
        "u3": DiscoverUserProfile(userId: "u3", username: "alex", displayName: "")
    ]
}
