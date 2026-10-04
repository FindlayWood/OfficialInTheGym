//
//  FollowStatusLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Where the signed-in user stands toward each of these users, so a followers
/// list can say "Follow back" or "Following" on each row.
public protocol FollowStatusLoader {
    func statuses(toward userIds: [String]) async throws -> [String: FollowStatus]
}
