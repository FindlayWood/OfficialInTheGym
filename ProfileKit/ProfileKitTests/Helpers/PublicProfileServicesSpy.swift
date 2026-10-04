//
//  PublicProfileServicesSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import Foundation
@testable import ProfileKit

/// Public-profile and search reads in one message log. Profile results are
/// queued, and the last one repeats, so a test can load and then refresh.
/// Search results are served per query. Never asserts — the test does.
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
        let result = profileResults.count > 1 ? profileResults.removeFirst() : profileResults[0]
        return try result.get()
    }

    func search(_ query: String, limit: Int) async throws -> [ProfileSummary] {
        receivedMessages.append(.search(query, limit: limit))
        if let searchError { throw searchError }
        return searchResults[query] ?? []
    }
}
