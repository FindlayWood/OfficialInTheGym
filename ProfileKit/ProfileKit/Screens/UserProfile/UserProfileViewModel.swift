//
//  UserProfileViewModel.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import Combine
import UIKit

/// Someone else's profile (`PROFILE_PLAN.md` step 7): the same header card as
/// your own, read from `Profiles/{uid}`, with a Follow button in place of Edit
/// Profile.
///
/// **A private account shows its header and counts to everyone, and its lists
/// only to approved followers** (`canSeeLists`). The counts stay visible but
/// stop being buttons, and a card says why. The rules enforce the same line
/// server-side, so a non-follower's list query would be denied anyway.
///
/// **Follow and unfollow show at once, counts included.** The server's recount
/// lags by a few seconds. Bumping the follower count locally when the status
/// becomes or stops being `.following` keeps the number and the button in
/// agreement meanwhile. A follow of a private account becomes `.requested`,
/// which changes no count.
///
/// Opened on your own id (your name in someone's list), it shows your public
/// profile with no Follow button. It is what others see, which is a fair
/// answer to "what does my profile look like?".
@MainActor
final class UserProfileViewModel: ObservableObject {

    enum LoadState: Equatable {
        case loading
        case loaded(PublicProfile)
        case notFound
        case failed
    }

    @Published private(set) var state: LoadState = .loading
    @Published private(set) var photo: UIImage?
    /// `nil` until read, and always `nil` on your own profile, which draws no
    /// button.
    @Published private(set) var followStatus: FollowStatus?
    @Published private(set) var isUpdatingFollow = false
    @Published private(set) var errorMessage: String?

    let userId: String
    private let currentUserId: String
    private let profileLoader: PublicProfileLoader
    private let photoLoader: ProfilePhotoLoader
    private let statusLoader: FollowStatusLoader
    private let followWriter: FollowWriter
    private let unfollower: Unfollower

    var onOpenFollowList: ((FollowListKind) -> Void)?

    init(
        userId: String,
        currentUserId: String,
        profileLoader: PublicProfileLoader,
        photoLoader: ProfilePhotoLoader,
        statusLoader: FollowStatusLoader,
        followWriter: FollowWriter,
        unfollower: Unfollower
    ) {
        self.userId = userId
        self.currentUserId = currentUserId
        self.profileLoader = profileLoader
        self.photoLoader = photoLoader
        self.statusLoader = statusLoader
        self.followWriter = followWriter
        self.unfollower = unfollower
    }

    var isOwnProfile: Bool { userId == currentUserId }

    var profile: PublicProfile? {
        if case .loaded(let profile) = state { return profile }
        return nil
    }

    var canSeeLists: Bool {
        guard let profile else { return false }
        return !profile.isPrivate || isOwnProfile || followStatus == .following
    }

    /// Unfollowing a private account loses access until a new request is
    /// approved, so the screen asks first. Unfollowing a public one is undone
    /// with one tap and does not.
    var unfollowNeedsConfirmation: Bool {
        profile?.isPrivate == true && followStatus == .following
    }

    /// Never premium: only the signed-in user's device knows that, and this is
    /// someone else (see `ProfileStamp`).
    var stamps: [ProfileStamp] {
        guard let profile else { return [] }
        return ProfileStamp.stamps(for: profile.header, hasUnlockedPro: false)
    }

    // MARK: - Load

    func load() async {
        if profile == nil { state = .loading }
        do {
            guard let loaded = try await profileLoader.profile(for: userId) else {
                state = .notFound
                return
            }
            state = .loaded(loaded)
            async let photo: Void = loadPhoto()
            async let status: Void = loadStatus()
            _ = await (photo, status)
        } catch {
            print("❌ User profile failed: \(error)")
            if profile == nil { state = .failed }
        }
    }

    private func loadPhoto() async {
        do {
            photo = try await photoLoader.photo(for: userId)
        } catch {
            print("❌ User profile photo failed: \(error)")
        }
    }

    private func loadStatus() async {
        guard !isOwnProfile else { return }
        do {
            followStatus = try await statusLoader.statuses(toward: [userId])[userId] ?? .notFollowing
        } catch {
            print("❌ Follow status failed: \(error)")
        }
    }

    // MARK: - Follow

    func toggleFollow() async {
        guard let current = followStatus, !isUpdatingFollow else { return }
        isUpdatingFollow = true
        errorMessage = nil
        defer { isUpdatingFollow = false }

        switch current {
        case .notFollowing:
            apply(.following, from: current)
            do {
                let result = try await followWriter.follow(userId)
                apply(result, from: .following)
            } catch {
                print("❌ Follow failed: \(error)")
                apply(current, from: .following)
                errorMessage = "Couldn't follow. Check your connection and try again."
            }
        case .following, .requested:
            apply(.notFollowing, from: current)
            do {
                try await unfollower.unfollow(userId)
            } catch {
                print("❌ Unfollow failed: \(error)")
                apply(current, from: .notFollowing)
                errorMessage = current == .requested
                    ? "Couldn't cancel the request. Check your connection and try again."
                    : "Couldn't unfollow. Check your connection and try again."
            }
        }
    }

    /// Sets the status and moves the follower count with it: +1 into
    /// `.following`, -1 out of it.
    private func apply(_ status: FollowStatus, from previous: FollowStatus) {
        followStatus = status
        guard let profile, (status == .following) != (previous == .following) else { return }
        let delta = status == .following ? 1 : -1
        state = .loaded(PublicProfile(
            header: profile.header,
            isPrivate: profile.isPrivate,
            counts: ProfileCounts(
                followers: max(0, profile.counts.followers + delta),
                following: profile.counts.following
            )
        ))
    }
}
