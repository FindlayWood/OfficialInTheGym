//
//  FollowRequestsLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// One page of requests waiting for the signed-in user's approval: pending
/// follows of them, newest first, resumed after `cursor`. Each entry's
/// `userId` is the person asking.
public protocol FollowRequestsLoader {
    func requests(after cursor: FollowListCursor?, limit: Int) async throws -> [FollowListEntry]
}
