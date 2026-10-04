//
//  PasswordResetServiceSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation
@testable import ProfileKit

/// Records every reset email sent. `error` is settable so a test can fail one
/// send and let the retry succeed. Never asserts — the test does.
final class PasswordResetServiceSpy: PasswordResetService, @unchecked Sendable {

    enum Message: Equatable {
        case sendPasswordReset
    }

    private(set) var receivedMessages: [Message] = []
    var error: Error?

    init(error: Error? = nil) {
        self.error = error
    }

    func sendPasswordReset() async throws {
        receivedMessages.append(.sendPasswordReset)
        if let error { throw error }
    }
}
