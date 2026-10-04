//
//  ModerationServicesSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import Foundation
@testable import ProfileKit

/// Reports, blocks and block status in one message log. Never asserts — the
/// test does.
final class ModerationServicesSpy: ProfileReporter, ProfileBlocker, ProfileBlockStatusLoader, @unchecked Sendable {

    enum Message: Equatable {
        case report(String, ProfileReportReason)
        case setBlocked(Bool, userId: String)
        case hasBlocked(String)
    }

    private(set) var receivedMessages: [Message] = []
    var hasBlockedResult = false
    var error: Error?

    func report(_ userId: String, reason: ProfileReportReason) async throws {
        receivedMessages.append(.report(userId, reason))
        if let error { throw error }
    }

    func setBlocked(_ blocked: Bool, userId: String) async throws {
        receivedMessages.append(.setBlocked(blocked, userId: userId))
        if let error { throw error }
    }

    func hasBlocked(_ userId: String) async throws -> Bool {
        receivedMessages.append(.hasBlocked(userId))
        return hasBlockedResult
    }
}
