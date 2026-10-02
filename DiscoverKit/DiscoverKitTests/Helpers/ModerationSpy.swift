//
//  ModerationSpy.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation
@testable import DiscoverKit

/// Records every report and block, and answers loads from fixed sets. Never
/// asserts — the test does.
final class ModerationSpy: BlockedUsersLoader, MyReportsLoader, ReportWriter, BlockedUsersWriter, @unchecked Sendable {

    enum Message: Equatable {
        case report(DiscoverReportTarget, DiscoverReportReason)
        case setBlocked(Bool, String)
    }

    private(set) var receivedMessages: [Message] = []
    var blocked: Set<String> = []
    var reported: Set<DiscoverReportTarget> = []
    var error: Error?

    func blockedUserIds() async throws -> Set<String> { blocked }

    func reportedTargets() async throws -> Set<DiscoverReportTarget> { reported }

    func report(_ target: DiscoverReportTarget, reason: DiscoverReportReason) async throws {
        receivedMessages.append(.report(target, reason))
        if let error { throw error }
    }

    func setBlocked(_ blocked: Bool, userId: String) async throws {
        receivedMessages.append(.setBlocked(blocked, userId))
        if let error { throw error }
    }
}
