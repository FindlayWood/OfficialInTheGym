//
//  BlockedUsersProfileBlocker.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import DiscoverKit
import ProfileKit

/// A profile's Block is DISCOVER's block, the same `BlockedUsersWriter`
/// writing the same `Users/{uid}/BlockedUsers/{id}`. It wraps it rather than
/// copying it, so there is one block and blocking from either place has the
/// same effect everywhere.
struct BlockedUsersProfileBlocker: ProfileBlocker {

    let wrapping: BlockedUsersWriter

    func setBlocked(_ blocked: Bool, userId: String) async throws {
        try await wrapping.setBlocked(blocked, userId: userId)
    }
}
