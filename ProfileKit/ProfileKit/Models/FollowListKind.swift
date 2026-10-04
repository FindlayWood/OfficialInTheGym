//
//  FollowListKind.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Which of a user's two lists: the people following them, or the people they
/// follow.
public enum FollowListKind: Equatable, Sendable {
    case followers
    case following

    var title: String {
        switch self {
        case .followers: "Followers"
        case .following: "Following"
        }
    }

    var emptyMessage: String {
        switch self {
        case .followers: "No followers yet."
        case .following: "Not following anyone yet."
        }
    }
}
