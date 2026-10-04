//
//  FollowServicesSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import Foundation
@testable import ProfileKit

/// Every follow read and write in one message log. Pages are queued and served
/// in order; results and errors are settable. Never asserts — the test does.
final class FollowServicesSpy: ProfileCountsLoader, FollowListLoader, ProfileSummaryLoader,
                               FollowStatusLoader, FollowWriter, Unfollower, FollowerRemover,
                               @unchecked Sendable {

    enum Message: Equatable {
        case counts(userId: String)
        case page(FollowListKind, userId: String, after: FollowListCursor?, limit: Int)
        case summaries(Set<String>)
        case statuses([String])
        case follow(String)
        case unfollow(String)
        case removeFollower(String)
    }

    private(set) var receivedMessages: [Message] = []
    var countsResult: Result<ProfileCounts?, Error> = .success(nil)
    var pages: [Result<[FollowListEntry], Error>] = []
    var summaries: [String: ProfileSummary] = [:]
    var statuses: [String: FollowStatus] = [:]
    var statusError: Error?
    var followResult: FollowStatus = .following
    var writeError: Error?

    func counts(for userId: String) async throws -> ProfileCounts? {
        receivedMessages.append(.counts(userId: userId))
        return try countsResult.get()
    }

    func page(_ kind: FollowListKind, of userId: String, after cursor: FollowListCursor?, limit: Int) async throws -> [FollowListEntry] {
        receivedMessages.append(.page(kind, userId: userId, after: cursor, limit: limit))
        return try pages.removeFirst().get()
    }

    func summaries(for userIds: Set<String>) async throws -> [String: ProfileSummary] {
        receivedMessages.append(.summaries(userIds))
        return summaries
    }

    func statuses(toward userIds: [String]) async throws -> [String: FollowStatus] {
        receivedMessages.append(.statuses(userIds))
        if let statusError { throw statusError }
        return statuses
    }

    func follow(_ userId: String) async throws -> FollowStatus {
        receivedMessages.append(.follow(userId))
        if let writeError { throw writeError }
        return followResult
    }

    func unfollow(_ userId: String) async throws {
        receivedMessages.append(.unfollow(userId))
        if let writeError { throw writeError }
    }

    func removeFollower(_ userId: String) async throws {
        receivedMessages.append(.removeFollower(userId))
        if let writeError { throw writeError }
    }
}
