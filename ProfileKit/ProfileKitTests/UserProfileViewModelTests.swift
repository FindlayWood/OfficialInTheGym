//
//  UserProfileViewModelTests.swift
//  ProfileKitTests
//
//  Created by Findlay Wood on 04/10/2026.
//

import XCTest
@testable import ProfileKit

@MainActor
final class UserProfileViewModelTests: XCTestCase {

    // MARK: - Load

    func test_load_deliversTheProfileAndFollowStatus() async {
        let sut = makeSUT(profile: profile(), status: .following)

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.state, .loaded(profile()))
        XCTAssertEqual(sut.viewModel.followStatus, .following)
    }

    func test_load_deliversNotFoundForAMissingProfile() async {
        let sut = makeSUT(profileResult: .success(nil))

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.state, .notFound)
    }

    func test_load_deliversFailedOnError() async {
        let sut = makeSUT(profileResult: .failure(anyError))

        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.state, .failed)
    }

    // Your own name in someone's list opens your public profile, with no
    // button to follow yourself.
    func test_load_offersNoFollowButtonOnYourOwnProfile() async {
        let sut = makeSUT(userId: "me", profile: profile(userId: "me"))

        await sut.viewModel.load()

        XCTAssertNil(sut.viewModel.followStatus)
        XCTAssertFalse(sut.follows.receivedMessages.contains { if case .statuses = $0 { true } else { false } })
    }

    // MARK: - Privacy

    func test_canSeeActivity_isTrueForAPublicAccount() async {
        let sut = makeSUT(profile: profile(isPrivate: false), status: .notFollowing)
        await sut.viewModel.load()

        XCTAssertTrue(sut.viewModel.canSeeActivity)
    }

    // A private account's lists are for approved followers. A pending request
    // is not approval.
    func test_canSeeActivity_isFalseForAPrivateAccountUntilFollowed() async {
        let notFollowing = makeSUT(profile: profile(isPrivate: true), status: .notFollowing)
        await notFollowing.viewModel.load()
        XCTAssertFalse(notFollowing.viewModel.canSeeActivity)

        let requested = makeSUT(profile: profile(isPrivate: true), status: .requested)
        await requested.viewModel.load()
        XCTAssertFalse(requested.viewModel.canSeeActivity)

        let following = makeSUT(profile: profile(isPrivate: true), status: .following)
        await following.viewModel.load()
        XCTAssertTrue(following.viewModel.canSeeActivity)
    }

    func test_unfollowNeedsConfirmation_onlyForAPrivateAccountYouFollow() async {
        let privateFollowed = makeSUT(profile: profile(isPrivate: true), status: .following)
        await privateFollowed.viewModel.load()
        XCTAssertTrue(privateFollowed.viewModel.unfollowNeedsConfirmation)

        let publicFollowed = makeSUT(profile: profile(isPrivate: false), status: .following)
        await publicFollowed.viewModel.load()
        XCTAssertFalse(publicFollowed.viewModel.unfollowNeedsConfirmation)
    }

    // Premium is only known on the signed-in user's device; someone else's
    // profile must never claim it.
    func test_stamps_neverIncludePremium() async {
        let sut = makeSUT(profile: profile(isElite: true), status: .notFollowing)
        await sut.viewModel.load()

        XCTAssertEqual(sut.viewModel.stamps, [.elite])
    }

    // MARK: - Highlights and clips

    func test_load_deliversHighlightsAndClipsForAPublicAccount() async {
        let sut = makeSUT(profile: profile(isPrivate: false), status: .notFollowing)
        sut.content.highlightsResult = .success(ProfileHighlights(highlights: [], isPinned: false))

        await sut.viewModel.load()

        XCTAssertTrue(sut.content.receivedMessages.contains(.highlights("alex")))
        XCTAssertNotNil(sut.viewModel.highlights)
    }

    // A private account's highlights are for followers; the rules would deny
    // the read, so the screen does not make it.
    func test_load_doesNotAskForAPrivateAccountsHighlightsUntilFollowing() async {
        let sut = makeSUT(profile: profile(isPrivate: true), status: .notFollowing)

        await sut.viewModel.load()

        XCTAssertFalse(sut.content.receivedMessages.contains(.highlights("alex")))
        XCTAssertNil(sut.viewModel.highlights)
    }

    // A clip marked public stays public, private account or not, as it does
    // in DISCOVER.
    func test_load_deliversAPrivateAccountsPublicClips() async {
        let sut = makeSUT(profile: profile(isPrivate: true), status: .notFollowing)

        await sut.viewModel.load()

        XCTAssertTrue(sut.content.receivedMessages.contains(.clips("alex", limit: MyProfileViewModel.clipLimit)))
    }

    // MARK: - Follow

    // The count moves with the button, so the two agree before the server's
    // recount arrives.
    func test_toggleFollow_followsAndBumpsTheFollowerCount() async {
        let sut = makeSUT(profile: profile(followers: 10), status: .notFollowing)
        await sut.viewModel.load()

        await sut.viewModel.toggleFollow()

        XCTAssertEqual(sut.follows.receivedMessages.last, .follow("alex"))
        XCTAssertEqual(sut.viewModel.followStatus, .following)
        XCTAssertEqual(sut.viewModel.profile?.counts.followers, 11)
    }

    // A follow of a private account comes back as a request, and a request is
    // not a follower.
    func test_toggleFollow_aRequestLeavesTheCountAlone() async {
        let sut = makeSUT(profile: profile(isPrivate: true, followers: 10), status: .notFollowing)
        sut.follows.followResult = .requested
        await sut.viewModel.load()

        await sut.viewModel.toggleFollow()

        XCTAssertEqual(sut.viewModel.followStatus, .requested)
        XCTAssertEqual(sut.viewModel.profile?.counts.followers, 10)
    }

    func test_toggleFollow_unfollowsAndDropsTheCount() async {
        let sut = makeSUT(profile: profile(followers: 10), status: .following)
        await sut.viewModel.load()

        await sut.viewModel.toggleFollow()

        XCTAssertEqual(sut.follows.receivedMessages.last, .unfollow("alex"))
        XCTAssertEqual(sut.viewModel.followStatus, .notFollowing)
        XCTAssertEqual(sut.viewModel.profile?.counts.followers, 9)
    }

    func test_toggleFollow_putsStatusAndCountBackOnFailure() async {
        let sut = makeSUT(profile: profile(followers: 10), status: .notFollowing)
        await sut.viewModel.load()
        sut.follows.writeError = anyError

        await sut.viewModel.toggleFollow()

        XCTAssertEqual(sut.viewModel.followStatus, .notFollowing)
        XCTAssertEqual(sut.viewModel.profile?.counts.followers, 10)
        XCTAssertNotNil(sut.viewModel.errorMessage)
    }

    // MARK: - Helpers

    private func makeSUT(
        userId: String = "alex",
        profile: PublicProfile? = nil,
        profileResult: Result<PublicProfile?, Error>? = nil,
        status: FollowStatus = .notFollowing
    ) -> (viewModel: UserProfileViewModel, profiles: PublicProfileServicesSpy, follows: FollowServicesSpy, content: ContentServicesSpy) {
        let profiles = PublicProfileServicesSpy()
        profiles.profileResults = [profileResult ?? .success(profile ?? self.profile())]
        let follows = FollowServicesSpy()
        follows.statuses = [userId: status]
        let content = ContentServicesSpy()
        let viewModel = UserProfileViewModel(
            userId: userId,
            currentUserId: "me",
            profileLoader: profiles,
            photoLoader: ProfilePhotoLoaderSpy(),
            statusLoader: follows,
            followWriter: follows,
            unfollower: follows,
            highlightsLoader: content,
            clipsLoader: content
        )
        return (viewModel, profiles, follows, content)
    }

    private func profile(
        userId: String = "alex",
        isPrivate: Bool = false,
        isElite: Bool = false,
        followers: Int = 5
    ) -> PublicProfile {
        PublicProfile(
            header: ProfileHeader(
                userId: userId,
                displayName: "Alex Morgan",
                username: "alex",
                bio: "",
                isVerified: false,
                isElite: isElite
            ),
            isPrivate: isPrivate,
            counts: ProfileCounts(followers: followers, following: 3)
        )
    }
}

private let anyError = NSError(domain: "test", code: 0)
