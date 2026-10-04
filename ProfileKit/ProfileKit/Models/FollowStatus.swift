//
//  FollowStatus.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Where the signed-in user stands toward someone: not following, asked to
/// follow a private account and waiting (step 6), or following.
public enum FollowStatus: Equatable, Sendable {
    case notFollowing
    case requested
    case following
}
