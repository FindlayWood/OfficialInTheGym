//
//  FollowListEntry.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// One row of a follow list: the other person in the relationship, and when
/// it began. `cursor` is where the next page starts.
public struct FollowListEntry: Equatable, Identifiable, Sendable {
    public let followId: String
    public let userId: String
    public let createdAt: Date

    public var id: String { followId }

    public init(followId: String, userId: String, createdAt: Date) {
        self.followId = followId
        self.userId = userId
        self.createdAt = createdAt
    }

    public var cursor: FollowListCursor {
        FollowListCursor(createdAt: createdAt, followId: followId)
    }
}

/// Where a page of a follow list resumes: newest first, by `createdAt` and
/// then by document id. **Both, not the date alone.** Every follow
/// `MigrateFollows.py` copies shares one timestamp, and a date-only cursor
/// would skip or repeat whole pages of them.
public struct FollowListCursor: Equatable, Sendable {
    public let createdAt: Date
    public let followId: String

    public init(createdAt: Date, followId: String) {
        self.createdAt = createdAt
        self.followId = followId
    }
}
