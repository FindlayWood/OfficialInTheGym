//
//  ProfileBlocker.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Blocks or unblocks someone. The same block DISCOVER writes
/// (`Users/{uid}/BlockedUsers/{id}`), so a block made on a profile hides their
/// comments and clips in DISCOVER too. Blocking removes follows both ways
/// server-side (`removeFollowsOnBlock`). Unblocking restores none of them.
public protocol ProfileBlocker {
    func setBlocked(_ blocked: Bool, userId: String) async throws
}
