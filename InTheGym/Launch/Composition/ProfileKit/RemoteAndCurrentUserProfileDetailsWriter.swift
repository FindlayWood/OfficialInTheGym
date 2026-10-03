//
//  RemoteAndCurrentUserProfileDetailsWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import ProfileKit

/// Saves remotely, then to the cached current user. It knows no paths and no
/// stores, only that both happen and in that order (*one writer, one
/// destination* in `CLAUDE.md`).
///
/// **Remote first, and the cache only on success.** Updating the cache first
/// would show the edit on every screen while the server never received it, and
/// it would disappear at the next launch. A failure stops before the cache, so
/// the screen's error is the whole truth.
struct RemoteAndCurrentUserProfileDetailsWriter: ProfileDetailsWriter {

    let remote: ProfileDetailsWriter
    let currentUser: ProfileDetailsWriter

    func save(_ details: ProfileDetails) async throws {
        try await remote.save(details)
        try await currentUser.save(details)
    }
}
