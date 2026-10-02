//
//  LikeWriterSpy.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation
@testable import DiscoverKit

/// Records every like and unlike. Never asserts — the test does.
final class LikeWriterSpy: LikeWriter, @unchecked Sendable {

    enum Message: Equatable {
        case setLiked(Bool, DiscoverLikeTarget)
    }

    private(set) var receivedMessages: [Message] = []
    var error: Error?

    func setLiked(_ liked: Bool, for target: DiscoverLikeTarget) async throws {
        receivedMessages.append(.setLiked(liked, target))
        if let error { throw error }
    }
}
