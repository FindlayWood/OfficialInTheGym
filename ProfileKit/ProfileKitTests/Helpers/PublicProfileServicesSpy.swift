//
//  PublicProfileServicesSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import Foundation
@testable import ProfileKit

/// Someone-else's-profile and search reads in one message log. Search results
/// are served per query, so a test can make an early search slow and a late
/// one fast. Never asserts — the test does.
final class PublicProfileServicesSpy: PublicProfileLoader, UserSearchLoader, @unchecked Sendable {

    enum Message: Equatable {
        case profile(String)
        case search(String, limit: Int)
    }

    private(set) var receivedMessages: [Message] = []
    var profileResults: [Result<PublicProfile?, Error>] = []
    var searchResults: [String: [ProfileSummary]] = [:]
    var searchError: Error?

    func profile(for userId: String) async throws -> PublicProfile? {
        receivedMessages.append(.profile(userId))
        return try profileResults.removeFirst().get()
    }

    func search(_ query: String, limit: Int) async throws -> [ProfileSummary] {
        receivedMessages.append(.search(query, limit: limit))
        if let searchError { throw searchError }
        return searchResults[query] ?? []
    }
}
