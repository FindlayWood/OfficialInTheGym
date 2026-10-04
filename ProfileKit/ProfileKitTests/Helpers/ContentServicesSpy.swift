//
//  ContentServicesSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import Foundation
@testable import ProfileKit

/// Highlights, clips, candidates and pins in one message log. Results and
/// errors are settable. Never asserts — the test does.
final class ContentServicesSpy: ProfileHighlightsLoader, ProfileClipsLoader,
                                HighlightCandidatesLoader, PinnedHighlightsWriter, @unchecked Sendable {

    enum Message: Equatable {
        case highlights(String)
        case clips(String, limit: Int)
        case candidates(limit: Int)
        case setPinned([String])
    }

    private(set) var receivedMessages: [Message] = []
    var highlightsResult: Result<ProfileHighlights?, Error> = .success(nil)
    var clipsResult: Result<[ProfileClip], Error> = .success([])
    var candidatesResult: Result<[ProfileHighlight], Error> = .success([])
    var writeError: Error?

    func highlights(for userId: String) async throws -> ProfileHighlights? {
        receivedMessages.append(.highlights(userId))
        return try highlightsResult.get()
    }

    func clips(of userId: String, limit: Int) async throws -> [ProfileClip] {
        receivedMessages.append(.clips(userId, limit: limit))
        return try clipsResult.get()
    }

    func candidates(limit: Int) async throws -> [ProfileHighlight] {
        receivedMessages.append(.candidates(limit: limit))
        return try candidatesResult.get()
    }

    func setPinned(_ exerciseIds: [String]) async throws {
        receivedMessages.append(.setPinned(exerciseIds))
        if let writeError { throw writeError }
    }
}
