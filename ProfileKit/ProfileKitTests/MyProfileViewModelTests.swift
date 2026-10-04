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

    func test_load_deliversTheFollowCountsFromThePublicProfile() async {
        let sut = makeSUT(results: [.success(.make(userId: "me"))], publicProfile: .success(publicProfile(followers: 4)))

        await sut.viewModel.load()

        XCTAssertEqual(sut.profiles.receivedMessages, [.profile("me")])
        XCTAssertEqual(sut.viewModel.counts, ProfileCounts(followers: 4, following: 2))
        XCTAssertEqual(sut.viewModel.publicProfile?.clipCount, 7)
    }

    // No profile document yet means no counts on screen, not "0 followers".
    func test_load_deliversNoCountsBeforeTheProfileExists() async {
        let sut = makeSUT(results: [.success(.make())], publicProfile: .success(nil))

        await sut.viewModel.load()

        XCTAssertNil(sut.viewModel.counts)
    }

    func test_refreshCounts_keepsTheShownCountsWhenTheReadFails() async {
        let sut = makeSUT(results: [.success(.make())], publicProfile: .success(publicProfile(followers: 4)))
        await sut.viewModel.load()
        sut.profiles.profileResults = [.failure(anyError)]

        await sut.viewModel.refreshCounts()

        XCTAssertEqual(sut.viewModel.counts, ProfileCounts(followers: 4, following: 2))
    }

    func test_refreshCounts_doesNothingBeforeTheHeaderLoads() async {
        let sut = makeSUT()

        await sut.viewModel.refreshCounts()

        XCTAssertTrue(sut.profiles.receivedMessages.isEmpty)
        XCTAssertTrue(sut.privacy.receivedMessages.isEmpty)
    }

    // MARK: - Highlights and clips

    func test_load_deliversHighlightsAndClips() async {
        let sut = makeSUT(results: [.success(.make(userId: "me"))])
        sut.content.highlightsResult = .success(ProfileHighlights(highlights: [highlight("squat")], isPinned: false))
        sut.content.clipsResult = .success([clip("c1")])

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.highlights?.highlights.map(\.exerciseId), ["squat"])
        XCTAssertEqual(sut.viewModel.clips.map(\.clipId), ["c1"])
    }

    // A failed section leaves only itself empty.
    func test_load_keepsTheClipsWhenHighlightsFail() async {
        let sut = makeSUT(results: [.success(.make())])
        sut.content.highlightsResult = .failure(anyError)
        sut.content.clipsResult = .success([clip("c1")])

        await sut.viewModel.load()

        XCTAssertNil(sut.viewModel.highlights)
        XCTAssertEqual(sut.viewModel.clips.map(\.clipId), ["c1"])
    }

    // The editor opens on the current choice; automatic highlights are not a
    // choice, so it opens with none picked.
    func test_editHighlights_passesThePinsOnlyWhenPinned() async {
        let pinned = makeSUT(results: [.success(.make())])
        pinned.content.highlightsResult = .success(ProfileHighlights(highlights: [highlight("curl")], isPinned: true))
        await pinned.viewModel.load()
        var received: [String]?
        pinned.viewModel.onEditHighlights = { received = $0 }
        pinned.viewModel.editHighlights()
        XCTAssertEqual(received, ["curl"])

        let automatic = makeSUT(results: [.success(.make())])
        automatic.content.highlightsResult = .success(ProfileHighlights(highlights: [highlight("squat")], isPinned: false))
        await automatic.viewModel.load()
        automatic.viewModel.onEditHighlights = { received = $0 }
        automatic.viewModel.editHighlights()
        XCTAssertEqual(received, [])
    }

    func test_applySavedHighlights_showsTheResultAtOnce() {
        let sut = makeSUT()

        sut.viewModel.applySavedHighlights(ProfileHighlights(highlights: [highlight("curl")], isPinned: true))

        XCTAssertEqual(sut.viewModel.highlights, ProfileHighlights(highlights: [highlight("curl")], isPinned: true))
    }

    func test_load_deliversThePendingRequestCount() async {
        let sut = makeSUT(results: [.success(.make())])
        sut.privacy.requestCountResult = .success(3)

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.pendingRequestCount, 3)
    }

    // Approving requests on the inbox has to clear the row on return, or it
    // would offer requests that are no longer there.
    func test_refreshCounts_updatesThePendingRequestCount() async {
        let sut = makeSUT(results: [.success(.make())])
        sut.privacy.requestCountResult = .success(3)
        await sut.viewModel.load()
        sut.privacy.requestCountResult = .success(0)

        await sut.viewModel.refreshCounts()

        XCTAssertEqual(sut.viewModel.pendingRequestCount, 0)
    }

    // MARK: - Helpers

    private func makeSUT(
        results: [Result<ProfileHeader, Error>] = [],
        photoResult: Result<UIImage?, Error> = .success(nil),
        publicProfile: Result<PublicProfile?, Error> = .success(nil),
        hasUnlockedPro: Bool = false
    ) -> (
        viewModel: MyProfileViewModel,
        loader: MyProfileLoaderSpy,
        photoLoader: ProfilePhotoLoaderSpy,
        profiles: PublicProfileServicesSpy,
        privacy: PrivacyServicesSpy,
        content: ContentServicesSpy
    ) {
        let loader = MyProfileLoaderSpy(results: results)
        let photoLoader = ProfilePhotoLoaderSpy(result: photoResult)
        let profiles = PublicProfileServicesSpy()
        profiles.profileResults = [publicProfile]
        let privacy = PrivacyServicesSpy()
        let content = ContentServicesSpy()
        let viewModel = MyProfileViewModel(
            profileLoader: loader,
            photoLoader: photoLoader,
            publicProfileLoader: profiles,
            requestCountLoader: privacy,
            highlightsLoader: content,
            clipsLoader: content,
            subscription: ProfileSubscriptionServiceSpy(hasUnlockedPro: hasUnlockedPro)
        )
        return (viewModel, loader, photoLoader, profiles, privacy, content)
    }

    private func publicProfile(followers: Int) -> PublicProfile {
        PublicProfile(header: .make(), isPrivate: false, counts: ProfileCounts(followers: followers, following: 2), clipCount: 7)
    }

    private func highlight(_ id: String) -> ProfileHighlight {
        ProfileHighlight(exerciseId: id, exerciseName: id, maxWeightKilograms: 100, maxTimeSeconds: 0, isTimeBased: false)
    }

    private func clip(_ id: String) -> ProfileClip {
        ProfileClip(
            clipId: id, exerciseId: nil, exerciseName: nil, videoURL: nil, thumbnailURL: nil, durationSeconds: nil,
            createdBy: "me", uploadedAt: nil, likeCount: nil, commentCount: nil, viewCount: nil
        )
    }

    private func loadedHeader(_ viewModel: MyProfileViewModel) -> ProfileHeader? {
        guard case .loaded(let header) = viewModel.header else { return nil }
        return header
    }
}

private let anyError = NSError(domain: "test", code: 0)
