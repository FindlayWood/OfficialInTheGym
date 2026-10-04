//
//  ProfilePhotoLoaderSpy.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//
import UIKit
@testable import ProfileKit

/// Records which user's photo was asked for. Never asserts — the test does.
final class ProfilePhotoLoaderSpy: ProfilePhotoLoader, @unchecked Sendable {

    enum Message: Equatable {
        case photo(userId: String)
    }

    private(set) var receivedMessages: [Message] = []
    private let result: Result<UIImage?, Error>

    init(result: Result<UIImage?, Error> = .success(nil)) {
        self.result = result
    }

    func photo(for userId: String) async throws -> UIImage? {
        receivedMessages.append(.photo(userId: userId))
        return try result.get()
    }
}
