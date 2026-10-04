//
//  PreviewPrivacyServices.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Preview conformer for private accounts and requests: a private account with
/// two requests waiting. Every write succeeds and stores nothing.
public final class PreviewPrivacyServices: PrivateAccountLoader, PrivateAccountWriter, FollowRequestsLoader,
                                           FollowRequestCountLoader, FollowRequestApprover, @unchecked Sendable {
    public init() {}

    public func isPrivate() async throws -> Bool { true }

    public func setPrivate(_ isPrivate: Bool) async throws {}

    public func requests(after cursor: FollowListCursor?, limit: Int) async throws -> [FollowListEntry] {
        guard cursor == nil else { return [] }
        return [
            FollowListEntry(followId: "u0_me", userId: "u0", createdAt: .now),
            FollowListEntry(followId: "u1_me", userId: "u1", createdAt: .now)
        ]
    }

    public func pendingRequestCount() async throws -> Int { 2 }

    public func approve(_ userId: String) async throws {}
}
