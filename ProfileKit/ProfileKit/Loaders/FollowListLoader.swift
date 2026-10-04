//
//  FollowListLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Loads one page of a user's followers or following, **active follows only**,
/// newest first, resuming after `cursor`.
public protocol FollowListLoader {
    func page(_ kind: FollowListKind, of userId: String, after cursor: FollowListCursor?, limit: Int) async throws -> [FollowListEntry]
}
