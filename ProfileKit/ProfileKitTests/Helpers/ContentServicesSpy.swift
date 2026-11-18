//
//  ContentServicesSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import Foundation
@testable import ProfileKit

/// Clip reads in one message log. The result is settable. Never asserts —
/// the test does.
final class ContentServicesSpy: ProfileClipsLoader, @unchecked Sendable {

    enum Message: Equatable {
        case clips(String, limit: Int)
    }

    private(set) var receivedMessages: [Message] = []
    var clipsResult: Result<[ProfileClip], Error> = .success([])

    func clips(of userId: String, limit: Int) async throws -> [ProfileClip] {
        receivedMessages.append(.clips(userId, limit: limit))
        return try clipsResult.get()
    }
}
