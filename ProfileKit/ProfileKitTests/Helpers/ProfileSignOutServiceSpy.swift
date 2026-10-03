//
//  ProfileSignOutServiceSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation
@testable import ProfileKit

/// Records every sign-out. Never asserts — the test does.
final class ProfileSignOutServiceSpy: ProfileSignOutService, @unchecked Sendable {

    enum Message: Equatable {
        case signOut
    }

    private(set) var receivedMessages: [Message] = []
    private let error: Error?

    init(error: Error? = nil) {
        self.error = error
    }

    func signOut() async throws {
        receivedMessages.append(.signOut)
        if let error { throw error }
    }
}
