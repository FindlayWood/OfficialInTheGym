//
//  BodyVoteWriterSpy.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation
@testable import DiscoverKit

/// Records every suggestion written. Never asserts — the test does.
final class BodyVoteWriterSpy: BodyVoteWriter, @unchecked Sendable {

    enum Message: Equatable {
        case setMyBodyVote(DiscoverBodyVote, exerciseId: String)
    }

    private(set) var receivedMessages: [Message] = []

    func setMyBodyVote(_ vote: DiscoverBodyVote, onExercise exerciseId: String) async throws {
        receivedMessages.append(.setMyBodyVote(vote, exerciseId: exerciseId))
    }
}
