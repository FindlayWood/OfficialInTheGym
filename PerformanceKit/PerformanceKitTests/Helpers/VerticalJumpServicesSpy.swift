//
//  VerticalJumpServicesSpy.swift
//  PerformanceKitTests
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation
@testable import PerformanceKit

/// Records every Vertical Jump load and save. Results are settable so a test
/// can fail one and let the retry succeed. Never asserts — the test does.
final class VerticalJumpServicesSpy: MaxVerticalJumpLoader, VerticalJumpHistoryLoader, VerticalJumpWriter, @unchecked Sendable {

    enum Message: Equatable {
        case loadMax
        case loadJumps
        case write(VerticalJumpSave)
    }

    private(set) var receivedMessages: [Message] = []
    var maxResult: Result<VerticalJump?, Error>
    var jumpsResult: Result<[VerticalJump], Error>
    var writeError: Error?

    init(
        maxResult: Result<VerticalJump?, Error> = .success(nil),
        jumpsResult: Result<[VerticalJump], Error> = .success([]),
        writeError: Error? = nil
    ) {
        self.maxResult = maxResult
        self.jumpsResult = jumpsResult
        self.writeError = writeError
    }

    func loadMax() async throws -> VerticalJump? {
        receivedMessages.append(.loadMax)
        return try maxResult.get()
    }

    func loadJumps() async throws -> [VerticalJump] {
        receivedMessages.append(.loadJumps)
        return try jumpsResult.get()
    }

    func write(_ save: VerticalJumpSave) async throws {
        receivedMessages.append(.write(save))
        if let writeError { throw writeError }
    }
}
