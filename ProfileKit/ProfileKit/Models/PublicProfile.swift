//
//  PublicProfile.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Someone else's profile as anyone may see it: the `Profiles/{uid}`
/// projection. It holds identity, whether the account is private, and the
/// follow counts. Never `Users/{uid}`, which other people cannot read
/// (`PROFILE_PLAN.md` step 2).
///
/// A private account's header and counts are public, as on every social app,
/// so someone deciding whether to request a follow can see who they are
/// asking. What a private account hides from non-followers is its lists (and,
/// from step 8, its highlights and clips).
public struct PublicProfile: Equatable, Sendable {
    public let header: ProfileHeader
    public let isPrivate: Bool
    public let counts: ProfileCounts
    /// Public, visible clips, recounted server-side (`profileClipCount`).
    public let clipCount: Int

    public init(header: ProfileHeader, isPrivate: Bool, counts: ProfileCounts, clipCount: Int = 0) {
        self.header = header
        self.isPrivate = isPrivate
        self.counts = counts
        self.clipCount = clipCount
    }
}
