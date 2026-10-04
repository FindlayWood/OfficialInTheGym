//
//  AccountDeleterSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import Foundation
@testable import ProfileKit

/// Records every deletion attempt. Never asserts — the test does.
final class AccountDeleterSpy: AccountDeleter, @unchecked Sendable {

    enum Message: Equatable {
        case deleteAccount(password: String)
    }

    private(set) var receivedMessages: [Message] = []
    var error: Error?

    func deleteAccount(password: String) async throws {
        receivedMessages.append(.deleteAccount(password: password))
        if let error { throw error }
    }
}
