//
//  MyProfileViewModel.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import Combine
import UIKit

/// The signed-in user's own profile.
///
/// The header: photo, name, @username, stamps, bio, and from step 5 of
/// `PROFILE_PLAN.md` the follower and following counts. The plan's sections
/// (highlights, clips) arrive later. **Counts are absent, not zero, until the
/// user's `Profiles` document exists.** A "0 followers" before the backfill would
/// be a claim, not a placeholder.
///
/// Counts are refreshed every time the tab reappears (`refreshCounts`), since
/// following someone from a list changes them. They lag by the trigger's few
/// seconds; pull to refresh catches up.
///
/// The header and the photo load independently. The photo is a second network
/// read (Storage) that can fail or simply not exist, and neither case may hold
/// the name back or turn the screen into an error. A failed photo leaves the
/// placeholder avatar, which is also what "no photo set" looks like.
@MainActor
final class MyProfileViewModel: ObservableObject {

    @Published private(set) var header: ProfileLoadState<ProfileHeader> = .loading
    @Published private(set) var photo: UIImage?
    @Published private(set) var counts: ProfileCounts?
    /// Requests waiting for approval. Zero, or a failed read, draws no row.
    @Published private(set) var pendingRequestCount = 0

    private let profileLoader: MyProfileLoader
    private let photoLoader: ProfilePhotoLoader
    private let countsLoader: ProfileCountsLoader
    private let requestCountLoader: FollowRequestCountLoader
    private let subscription: ProfileSubscriptionService

    var onOpenSettings: (() -> Void)?
    var onEditProfile: ((ProfileHeader, UIImage?) -> Void)?
    var onOpenFollowList: ((FollowListKind) -> Void)?
    var onOpenFollowRequests: (() -> Void)?
    var onOpenSearch: (() -> Void)?

    init(
        profileLoader: MyProfileLoader,
        photoLoader: ProfilePhotoLoader,
        countsLoader: ProfileCountsLoader,
        requestCountLoader: FollowRequestCountLoader,
        subscription: ProfileSubscriptionService
    ) {
        self.profileLoader = profileLoader
        self.photoLoader = photoLoader
        self.countsLoader = countsLoader
        self.requestCountLoader = requestCountLoader
        self.subscription = subscription
    }

    /// Premium is passed in because this is your own profile. See `ProfileStamp`.
    var stamps: [ProfileStamp] {
        guard case .loaded(let header) = header else { return [] }
        return ProfileStamp.stamps(for: header, hasUnlockedPro: subscription.hasUnlockedPro)
    }

    func editProfile() {
        guard case .loaded(let header) = header else { return }
        onEditProfile?(header, photo)
    }

    func load() async {
        // A refresh keeps the header on screen. Only a first load shows the skeleton.
        if case .failed = header { header = .loading }
        do {
            let loaded = try await profileLoader.load()
            header = .loaded(loaded)
            async let photo: Void = loadPhoto(for: loaded.userId)
            async let counts: Void = loadCounts(for: loaded.userId)
            _ = await (photo, counts)
        } catch {
            print("❌ Profile header failed: \(error)")
            if case .loaded = header { return }
            header = .failed
        }
    }

    /// Called when the tab reappears. Only the counts, which a follow list may
    /// have changed; the rest of the header cannot change behind the screen.
    func refreshCounts() async {
        guard case .loaded(let header) = header else { return }
        await loadCounts(for: header.userId)
    }

    /// A failed read keeps whatever counts were already shown. The request
    /// count travels with the follow counts: approving a request changes both.
    private func loadCounts(for userId: String) async {
        do {
            counts = try await countsLoader.counts(for: userId)
        } catch {
            print("❌ Profile counts failed: \(error)")
        }
        do {
            pendingRequestCount = try await requestCountLoader.pendingRequestCount()
        } catch {
            print("❌ Follow request count failed: \(error)")
        }
    }

    private func loadPhoto(for userId: String) async {
        do {
            photo = try await photoLoader.photo(for: userId)
        } catch {
            print("❌ Profile photo failed: \(error)")
        }
    }
}
