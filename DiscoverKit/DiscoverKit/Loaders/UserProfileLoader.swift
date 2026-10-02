//
//  UserProfileLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Profiles for a set of user ids, keyed by id. An id with no profile — a
/// deleted account — is simply absent from the result, not an error; the row
/// shows "Deleted user".
public protocol UserProfileLoader {
    func profiles(for userIds: Set<String>) async throws -> [String: DiscoverUserProfile]
}
