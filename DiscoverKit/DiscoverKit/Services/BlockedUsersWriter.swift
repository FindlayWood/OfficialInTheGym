//
//  BlockedUsersWriter.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Blocks or unblocks a user for the signed-in user. Blocking is one-way and
/// private — the blocked user is not told and sees no difference.
public protocol BlockedUsersWriter {
    func setBlocked(_ blocked: Bool, userId: String) async throws
}
