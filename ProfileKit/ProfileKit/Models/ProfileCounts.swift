//
//  ProfileCounts.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Follower and following counts, read from `Profiles/{uid}`, where only the
/// `profileFollowCounts` function writes them. They are recounts of active
/// follows, so a pending request is not a follower.
///
/// Counts lag a follow by the trigger's few seconds. The lists are the truth
/// and the counts catch up.
public struct ProfileCounts: Equatable, Sendable {
    public let followers: Int
    public let following: Int

    public init(followers: Int, following: Int) {
        self.followers = followers
        self.following = following
    }
}
