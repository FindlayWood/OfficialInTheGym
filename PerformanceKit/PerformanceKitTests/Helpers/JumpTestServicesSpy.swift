//
//  JumpTestServicesSpy.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation
@testable import PerformanceKit

/// Records every jump-test load and save. Results are settable so a test can
/// fail one and let the retry succeed. Never asserts — the test does.
final class JumpTestServicesSpy: JumpTestSessionsLoader, JumpTestSessionWriter, @unchecked Sendable {

    enum Message: Equatable {
        case loadSessions(JumpTestKind)
        case write(JumpTestSession)
    }

    private(set) var receivedMessages: [Message] = []
    var sessionsResult: Result<[JumpTestSession], Error>
    var writeError: Error?

    init(sessionsResult: Result<[JumpTestSession], Error> = .success([]), writeError: Error? = nil) {
        self.sessionsResult = sessionsResult
        self.writeError = writeError
    }

    func loadSessions(_ kind: JumpTestKind) async throws -> [JumpTestSession] {
        receivedMessages.append(.loadSessions(kind))
        return try sessionsResult.get()
    }

    func write(_ session: JumpTestSession) async throws {
        receivedMessages.append(.write(session))
        if let writeError { throw writeError }
    }
}
