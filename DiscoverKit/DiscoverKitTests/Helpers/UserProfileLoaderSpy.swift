//
//  UserProfileLoaderSpy.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation
@testable import DiscoverKit

/// Records every set of ids asked for, and answers from a fixed table.
final class UserProfileLoaderSpy: UserProfileLoader, @unchecked Sendable {

    enum Message: Equatable {
        case profiles(Set<String>)
    }

    private(set) var receivedMessages: [Message] = []
    private let table: [String: DiscoverUserProfile]

    init(table: [String: DiscoverUserProfile]) {
        self.table = table
    }

    func profiles(for userIds: Set<String>) async throws -> [String: DiscoverUserProfile] {
        receivedMessages.append(.profiles(userIds))
        return table.filter { userIds.contains($0.key) }
    }
}
