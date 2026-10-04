//
//  PrivacyServicesSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import Foundation
@testable import ProfileKit

/// Private-account and request reads and writes in one message log. Results
/// and errors are settable. Never asserts — the test does.
final class PrivacyServicesSpy: PrivateAccountLoader, PrivateAccountWriter, FollowRequestsLoader,
                                FollowRequestCountLoader, FollowRequestApprover, @unchecked Sendable {

    enum Message: Equatable {
        case isPrivate
        case setPrivate(Bool)
        case requests(after: FollowListCursor?, limit: Int)
        case pendingRequestCount
        case approve(String)
    }

    private(set) var receivedMessages: [Message] = []
    var isPrivateResult: Result<Bool, Error> = .success(false)
    var requestPages: [Result<[FollowListEntry], Error>] = []
    var requestCountResult: Result<Int, Error> = .success(0)
    var writeError: Error?

    func isPrivate() async throws -> Bool {
        receivedMessages.append(.isPrivate)
        return try isPrivateResult.get()
    }

    func setPrivate(_ isPrivate: Bool) async throws {
        receivedMessages.append(.setPrivate(isPrivate))
        if let writeError { throw writeError }
    }

    func requests(after cursor: FollowListCursor?, limit: Int) async throws -> [FollowListEntry] {
        receivedMessages.append(.requests(after: cursor, limit: limit))
        return try requestPages.removeFirst().get()
    }

    func pendingRequestCount() async throws -> Int {
        receivedMessages.append(.pendingRequestCount)
        return try requestCountResult.get()
    }

    func approve(_ userId: String) async throws {
        receivedMessages.append(.approve(userId))
        if let writeError { throw writeError }
    }
}
