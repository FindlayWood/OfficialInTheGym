//
//  FollowRequestCountLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// How many requests are waiting, for the row on the profile that opens them.
/// A count query, not a list, since the row needs only the number.
public protocol FollowRequestCountLoader {
    func pendingRequestCount() async throws -> Int
}
