//
//  MyProfileLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// Loads the signed-in user's own header.
///
/// It is separate from loading someone else's profile on purpose. Your own
/// profile can be answered from what the app already holds about you, and
/// someone else's is a read of `Profiles/{uid}` (step 2) that has to be allowed
/// to fail. A single `header(for:)` would make an adapter that only knows the
/// current user throw for everyone else, a lie in the protocol.
public protocol MyProfileLoader {
    func load() async throws -> ProfileHeader
}
