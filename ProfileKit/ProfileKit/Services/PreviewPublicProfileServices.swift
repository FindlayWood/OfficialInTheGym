//
//  PreviewPublicProfileServices.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Preview conformer for someone else's profile and for search: a public
/// account with counts, and a couple of matches for any query.
public final class PreviewPublicProfileServices: PublicProfileLoader, UserSearchLoader, @unchecked Sendable {

    private let isPrivate: Bool

    public init(isPrivate: Bool = false) {
        self.isPrivate = isPrivate
    }

    public func profile(for userId: String) async throws -> PublicProfile? {
        PublicProfile(
            header: ProfileHeader(
                userId: userId,
                displayName: "Alex Morgan",
                username: "alex",
                bio: "Powerlifter. Squat day is the best day.",
                isVerified: false,
                isElite: true
            ),
            isPrivate: isPrivate,
            counts: ProfileCounts(followers: 128, following: 54)
        )
    }

    public func search(_ query: String, limit: Int) async throws -> [ProfileSummary] {
        [
            ProfileSummary(userId: "u0", username: "\(query)alex", displayName: "Alex Morgan"),
            ProfileSummary(userId: "u1", username: "\(query)sam", displayName: "Sam Reid")
        ]
    }
}
