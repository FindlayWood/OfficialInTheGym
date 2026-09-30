//
//  CachingUserProfileLoaderTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 30/09/2026.
//

import XCTest
@testable import DiscoverKit

final class CachingUserProfileLoaderTests: XCTestCase {

    func test_profiles_deliversProfilesFromDecoratee() async throws {
        let (sut, _) = makeSUT()

        let profiles = try await sut.profiles(for: ["u1"])

        XCTAssertEqual(profiles["u1"]?.displayName, "Findlay")
    }

    // The cache is the point: a thread is mostly the same few people, and each
    // page or opened reply thread would otherwise re-read their documents.
    func test_profiles_doesNotAskAgainForAnIdAlreadyLoaded() async throws {
        let (sut, spy) = makeSUT()

        _ = try await sut.profiles(for: ["u1"])
        _ = try await sut.profiles(for: ["u1", "u2"])

        XCTAssertEqual(spy.receivedMessages, [.profiles(["u1"]), .profiles(["u2"])])
    }

    // A deleted user's id appears on every page their comments do; without
    // remembering the miss it would be looked up again each time.
    func test_profiles_doesNotAskAgainForAnIdThatWasNotFound() async throws {
        let (sut, spy) = makeSUT()

        _ = try await sut.profiles(for: ["gone"])
        let profiles = try await sut.profiles(for: ["gone"])

        XCTAssertTrue(profiles.isEmpty)
        XCTAssertEqual(spy.receivedMessages, [.profiles(["gone"])])
    }

    // MARK: - Helpers

    private func makeSUT() -> (CachingUserProfileLoader, UserProfileLoaderSpy) {
        let spy = UserProfileLoaderSpy(table: [
            "u1": DiscoverUserProfile(userId: "u1", username: "findlay", displayName: "Findlay"),
            "u2": DiscoverUserProfile(userId: "u2", username: "sam", displayName: "Sam")
        ])
        return (CachingUserProfileLoader(decoratee: spy), spy)
    }
}
