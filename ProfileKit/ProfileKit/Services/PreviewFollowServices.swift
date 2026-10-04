//
//  PreviewFollowServices.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Preview conformer for everything follows: a short list, and writes that
/// succeed and store nothing. A follow comes back `.following`.
public final class PreviewFollowServices: FollowListLoader, ProfileSummaryLoader,
                                          FollowStatusLoader, FollowWriter, Unfollower, FollowerRemover,
                                          @unchecked Sendable {
    private let names = ["Alex Morgan", "Sam Reid", "Jordan Lee", "Taylor Kim"]

    public init() {}

    public func page(_ kind: FollowListKind, of userId: String, after cursor: FollowListCursor?, limit: Int) async throws -> [FollowListEntry] {
        guard cursor == nil else { return [] }
        return names.indices.map { FollowListEntry(followId: "f\($0)", userId: "u\($0)", createdAt: .now) }
    }

    public func summaries(for userIds: Set<String>) async throws -> [String: ProfileSummary] {
        var result: [String: ProfileSummary] = [:]
        for (index, name) in names.enumerated() where userIds.contains("u\(index)") {
            result["u\(index)"] = ProfileSummary(
                userId: "u\(index)",
                username: name.split(separator: " ").first!.lowercased(),
                displayName: name
            )
        }
        return result
    }

    public func statuses(toward userIds: [String]) async throws -> [String: FollowStatus] {
        Dictionary(uniqueKeysWithValues: userIds.enumerated().map { ($1, $0.isMultiple(of: 2) ? .following : .notFollowing) })
    }

    public func follow(_ userId: String) async throws -> FollowStatus { .following }

    public func unfollow(_ userId: String) async throws {}

    public func removeFollower(_ userId: String) async throws {}
}
