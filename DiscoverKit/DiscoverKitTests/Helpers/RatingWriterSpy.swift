//
//  RatingWriterSpy.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation
@testable import DiscoverKit

/// Records every rating written. Never asserts — the test does.
final class RatingWriterSpy: RatingWriter, @unchecked Sendable {

    enum Message: Equatable {
        case setRating(Int, DiscoverSubject)
    }

    private(set) var receivedMessages: [Message] = []
    private let error: Error?

    init(error: Error? = nil) {
        self.error = error
    }

    func setRating(_ rating: Int, for subject: DiscoverSubject) async throws {
        receivedMessages.append(.setRating(rating, subject))
        if let error { throw error }
    }
}
