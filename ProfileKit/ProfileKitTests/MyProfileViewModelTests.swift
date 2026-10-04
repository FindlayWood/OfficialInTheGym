//
//  MyProfileViewModelTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 03/10/2026.
//

import UIKit
import XCTest
@testable import ProfileKit

@MainActor
final class MyProfileViewModelTests: XCTestCase {

    func test_init_deliversLoadingBeforeTheFirstLoad() {
        let sut = makeSUT()

        guard case .loading = sut.viewModel.header else {
            return XCTFail("Expected .loading, got \(sut.viewModel.header)")
        }
    }

    func test_load_deliversHeaderAndAsksForThatUsersPhoto() async {
        let photo = UIImage()
        let sut = makeSUT(results: [.success(.make(userId: "me"))], photoResult: .success(photo))

        await sut.viewModel.load()

        XCTAssertEqual(loadedHeader(sut.viewModel), .make(userId: "me"))
        XCTAssertEqual(sut.photoLoader.receivedMessages, [.photo(userId: "me")])
        XCTAssertTrue(sut.viewModel.photo === photo)
    }

    // The photo is a second read that can fail on its own. Turning the whole
    // screen into an error for it would hide the name the user just loaded.
    func test_load_keepsTheHeaderWhenThePhotoFails() async {
        let sut = makeSUT(results: [.success(.make())], photoResult: .failure(anyError))

        await sut.viewModel.load()

        XCTAssertEqual(loadedHeader(sut.viewModel), .make())
        XCTAssertNil(sut.viewModel.photo)
    }

    func test_load_deliversFailedWhenTheHeaderFails() async {
        let sut = makeSUT(results: [.failure(anyError)])

        await sut.viewModel.load()

        guard case .failed = sut.viewModel.header else {
            return XCTFail("Expected .failed, got \(sut.viewModel.header)")
        }
        XCTAssertTrue(sut.photoLoader.receivedMessages.isEmpty)
    }

    // A pull-to-refresh that fails must not blank a profile that is already on
    // screen. Offline means stale, not broken, the rule the workout library
    // learned the hard way.
    func test_load_keepsTheLoadedHeaderWhenARefreshFails() async {
        let sut = makeSUT(results: [.success(.make()), .failure(anyError)])
        await sut.viewModel.load()

        await sut.viewModel.load()

        XCTAssertEqual(loadedHeader(sut.viewModel), .make())
    }

    func test_load_recoversFromFailedOnRetry() async {
        let sut = makeSUT(results: [.failure(anyError), .success(.make())])
        await sut.viewModel.load()

        await sut.viewModel.load()

        XCTAssertEqual(loadedHeader(sut.viewModel), .make())
    }

    func test_stamps_includesPremiumForASubscribedUser() async {
        let sut = makeSUT(results: [.success(.make(isVerified: true))], hasUnlockedPro: true)

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.stamps, [.verified, .premium])
    }

    func test_stamps_deliversNoneBeforeTheHeaderLoads() {
        let sut = makeSUT(hasUnlockedPro: true)

        XCTAssertEqual(sut.viewModel.stamps, [])
    }

    func test_editProfile_passesTheLoadedHeaderAndPhoto() async {
        let photo = UIImage()
        let sut = makeSUT(results: [.success(.make(userId: "me"))], photoResult: .success(photo))
        await sut.viewModel.load()
        var received: (ProfileHeader, UIImage?)?
        sut.viewModel.onEditProfile = { received = ($0, $1) }

        sut.viewModel.editProfile()

        XCTAssertEqual(received?.0, .make(userId: "me"))
        XCTAssertTrue(received?.1 === photo)
    }

    // There is nothing to edit before the header loads, and an editor opened
    // on empty fields would save them over the real name.
    func test_editProfile_doesNothingBeforeTheHeaderLoads() {
        let sut = makeSUT()
        var opened = false
        sut.viewModel.onEditProfile = { _, _ in opened = true }

        sut.viewModel.editProfile()

        XCTAssertFalse(opened)
    }

    func test_load_deliversTheFollowCounts() async {
        let sut = makeSUT(results: [.success(.make(userId: "me"))], counts: .success(ProfileCounts(followers: 4, following: 2)))

        await sut.viewModel.load()

        XCTAssertEqual(sut.follows.receivedMessages, [.counts(userId: "me")])
        XCTAssertEqual(sut.viewModel.counts, ProfileCounts(followers: 4, following: 2))
    }

    // No profile document yet means no counts on screen, not "0 followers".
    func test_load_deliversNoCountsBeforeTheProfileExists() async {
        let sut = makeSUT(results: [.success(.make())], counts: .success(nil))

        await sut.viewModel.load()

        XCTAssertNil(sut.viewModel.counts)
    }

    func test_refreshCounts_keepsTheShownCountsWhenTheReadFails() async {
        let sut = makeSUT(results: [.success(.make())], counts: .success(ProfileCounts(followers: 4, following: 2)))
        await sut.viewModel.load()
        sut.follows.countsResult = .failure(anyError)

        await sut.viewModel.refreshCounts()

        XCTAssertEqual(sut.viewModel.counts, ProfileCounts(followers: 4, following: 2))
    }

    func test_refreshCounts_doesNothingBeforeTheHeaderLoads() async {
        let sut = makeSUT()

        await sut.viewModel.refreshCounts()

        XCTAssertTrue(sut.follows.receivedMessages.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(
        results: [Result<ProfileHeader, Error>] = [],
        photoResult: Result<UIImage?, Error> = .success(nil),
        counts: Result<ProfileCounts?, Error> = .success(nil),
        hasUnlockedPro: Bool = false
    ) -> (viewModel: MyProfileViewModel, loader: MyProfileLoaderSpy, photoLoader: ProfilePhotoLoaderSpy, follows: FollowServicesSpy) {
        let loader = MyProfileLoaderSpy(results: results)
        let photoLoader = ProfilePhotoLoaderSpy(result: photoResult)
        let follows = FollowServicesSpy()
        follows.countsResult = counts
        let viewModel = MyProfileViewModel(
            profileLoader: loader,
            photoLoader: photoLoader,
            countsLoader: follows,
            subscription: ProfileSubscriptionServiceSpy(hasUnlockedPro: hasUnlockedPro)
        )
        return (viewModel, loader, photoLoader, follows)
    }

    private func loadedHeader(_ viewModel: MyProfileViewModel) -> ProfileHeader? {
        guard case .loaded(let header) = viewModel.header else { return nil }
        return header
    }
}

private let anyError = NSError(domain: "test", code: 0)
