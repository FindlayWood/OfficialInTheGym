//
//  TagVoteWriterSpy.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation
@testable import DiscoverKit

/// Records every tag set written. Never asserts — the test does.
final class TagVoteWriterSpy: TagVoteWriter, @unchecked Sendable {

    enum Message: Equatable {
        case setMyTags([String], DiscoverSubject)
    }

    private(set) var receivedMessages: [Message] = []
    var error: Error?

    func setMyTags(_ tags: [String], on subject: DiscoverSubject) async throws {
        receivedMessages.append(.setMyTags(tags, subject))
        if let error { throw error }
    }
}
