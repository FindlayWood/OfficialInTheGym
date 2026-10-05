//
//  DiscoverAuthorDirectoryTests.swift
//  DiscoverKitTests
//
//  Created by Findlay Wood on 05/10/2026.
//

import XCTest
@testable import DiscoverKit

@MainActor
final class DiscoverAuthorDirectoryTests: XCTestCase {

    // A list draws its rows in one pass; one lookup per row would be one read
    // per row where a single batched query does.
    func test_flush_loadsEveryIdRequestedInOneCall() async {
        let (sut, spy) = makeSUT()

        sut.request("u1")
        sut.request("u2")
        sut.request("u1")
        await sut.flush()

        XCTAssertEqual(spy.receivedMessages, [.profiles(["u1", "u2"])])
        XCTAssertEqual(sut.name(for: "u1"), "Findlay")
        XCTAssertEqual(sut.name(for: "u2"), "Sam")
    }

    func test_request_doesNotAskAgainForAnIdAlreadyRequested() async {
        let (sut, spy) = makeSUT()
        sut.request("u1")
        await sut.flush()

        sut.request("u1")
        await sut.flush()

        XCTAssertEqual(spy.receivedMessages, [.profiles(["u1"])])
    }

    // Your own workouts need no lookup to say who made them.
    func test_name_deliversYouForTheCurrentUserWithoutALookup() async {
        let (sut, spy) = makeSUT(currentUserId: "me")

        sut.request("me")
        await sut.flush()

        XCTAssertEqual(sut.name(for: "me"), "You")
        XCTAssertTrue(spy.receivedMessages.isEmpty)
    }

    // A deleted account has no name; the row shows no byline rather than an id.
    func test_name_deliversNilForAnIdWithNoProfile() async {
        let (sut, _) = makeSUT()

        sut.request("gone")
        await sut.flush()

        XCTAssertNil(sut.name(for: "gone"))
    }

    // MARK: - Helpers

    private func makeSUT(currentUserId: String = "current") -> (DiscoverAuthorDirectory, UserProfileLoaderSpy) {
        let spy = UserProfileLoaderSpy(table: [
            "u1": DiscoverUserProfile(userId: "u1", username: "findlay", displayName: "Findlay"),
            "u2": DiscoverUserProfile(userId: "u2", username: "sam", displayName: "Sam")
        ])
        return (DiscoverAuthorDirectory(loader: spy, currentUserId: currentUserId), spy)
    }
}
