//
//  PreviewPublicProfileServices.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Preview conformer for someone else's profile: a public account with counts.
public final class PreviewPublicProfileServices: PublicProfileLoader, @unchecked Sendable {

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
}
