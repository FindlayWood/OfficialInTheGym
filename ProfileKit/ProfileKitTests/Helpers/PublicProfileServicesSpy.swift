//
//  PublicProfileServicesSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import Foundation
@testable import ProfileKit

/// Public-profile reads in one message log. Results are queued, and the last
/// one repeats, so a test can load and then refresh. Never asserts — the test
/// does.
final class PublicProfileServicesSpy: PublicProfileLoader, @unchecked Sendable {

    enum Message: Equatable {
        case profile(String)
    }

    private(set) var receivedMessages: [Message] = []
    var profileResults: [Result<PublicProfile?, Error>] = []

    func profile(for userId: String) async throws -> PublicProfile? {
        receivedMessages.append(.profile(userId))
        let result = profileResults.count > 1 ? profileResults.removeFirst() : profileResults[0]
        return try result.get()
    }
}
