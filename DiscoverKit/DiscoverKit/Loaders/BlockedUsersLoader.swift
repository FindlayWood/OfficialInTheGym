//
//  BlockedUsersLoader.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// The users the signed-in user has blocked.
public protocol BlockedUsersLoader {
    func blockedUserIds() async throws -> Set<String>
}
