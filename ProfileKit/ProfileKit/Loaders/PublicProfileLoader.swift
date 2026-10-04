//
//  PublicProfileLoader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Loads anyone's public profile. `nil` means there is no such profile: a
/// deleted account, or one created before the backfill. The screen says so,
/// rather than showing an error the user could retry forever.
public protocol PublicProfileLoader {
    func profile(for userId: String) async throws -> PublicProfile?
}
