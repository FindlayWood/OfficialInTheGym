//
//  MyProfileLoaderSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation
@testable import ProfileKit

/// Delivers queued results in order, one per load. Never asserts — the test does.
final class MyProfileLoaderSpy: MyProfileLoader, @unchecked Sendable {

    enum Message: Equatable {
        case load
    }

    private(set) var receivedMessages: [Message] = []
    private var results: [Result<ProfileHeader, Error>]

    init(results: [Result<ProfileHeader, Error>]) {
        self.results = results
    }

    func load() async throws -> ProfileHeader {
        receivedMessages.append(.load)
        return try results.removeFirst().get()
    }
}
