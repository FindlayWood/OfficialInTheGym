//
//  BalanceServicesSpy.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation
@testable import PerformanceKit

/// Records every balance load and save. Never asserts — the test does.
final class BalanceServicesSpy: BalanceSessionsLoader, BalanceSessionWriter, @unchecked Sendable {

    enum Message: Equatable {
        case load
        case write(BalanceSession)
    }

    private(set) var receivedMessages: [Message] = []
    var sessions: [BalanceSession] = []
    var writeError: Error?

    func loadBalanceSessions() async throws -> [BalanceSession] {
        receivedMessages.append(.load)
        return sessions
    }

    func write(_ session: BalanceSession) async throws {
        receivedMessages.append(.write(session))
        if let writeError { throw writeError }
    }
}
