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
/// `PROFILE_PLAN.md` the follower and following counts, then from step 8 the
/// highlights and clips sections, the same ones other people see. **Counts are absent, not zero, until the
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
    /// Your public profile as others see it, the source of the counts and the
    /// clip count. The header itself comes from the cached user, which is
    /// fresher after an edit than the projection.
    @Published private(set) var publicProfile: PublicProfile?
    /// Requests waiting for approval. Zero, or a failed read, draws no row.
    @Published private(set) var pendingRequestCount = 0
    @Published private(set) var highlights: ProfileHighlights?
    @Published private(set) var clips: [ProfileClip] = []

    static let clipLimit = 12

    private let profileLoader: MyProfileLoader
    private let photoLoader: ProfilePhotoLoader
    private let publicProfileLoader: PublicProfileLoader
    private let requestCountLoader: FollowRequestCountLoader
    private let highlightsLoader: ProfileHighlightsLoader
    private let clipsLoader: ProfileClipsLoader
    private let subscription: ProfileSubscriptionService

    var onOpenSettings: (() -> Void)?
    var onEditProfile: ((ProfileHeader, UIImage?) -> Void)?
    var onOpenFollowList: ((FollowListKind) -> Void)?
    var onOpenFollowRequests: (() -> Void)?
    var onOpenSearch: (() -> Void)?
    /// The current pins, empty when highlights are automatic.
    var onEditHighlights: (([String]) -> Void)?
    var onOpenClip: ((ProfileClip) -> Void)?

    init(
        profileLoader: MyProfileLoader,
        photoLoader: ProfilePhotoLoader,
        publicProfileLoader: PublicProfileLoader,
        requestCountLoader: FollowRequestCountLoader,
        highlightsLoader: ProfileHighlightsLoader,
        clipsLoader: ProfileClipsLoader,
        subscription: ProfileSubscriptionService
    ) {
        self.profileLoader = profileLoader
        self.photoLoader = photoLoader
        self.publicProfileLoader = publicProfileLoader
        self.requestCountLoader = requestCountLoader
        self.highlightsLoader = highlightsLoader
        self.clipsLoader = clipsLoader
        self.subscription = subscription
    }

    var counts: ProfileCounts? { publicProfile?.counts }

    func editHighlights() {
        let pins = highlights?.isPinned == true ? highlights?.highlights.map(\.exerciseId) ?? [] : []
        onEditHighlights?(pins)
    }

    /// The editor's result, shown at once. The server's rebuild of
    /// `ProfileHighlights` lags by a few seconds.
    func applySavedHighlights(_ saved: ProfileHighlights) {
        highlights = saved
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
            async let content: Void = loadContent(for: loaded.userId)
            _ = await (photo, counts, content)
        } catch {
            print("❌ Profile header failed: \(error)")
            if case .loaded = header { return }
            header = .failed
        }
    }

    /// Called when the tab reappears: the counts, which a follow list may have
    /// changed, and the clips, which a clip opened from the grid may have been
    /// liked or deleted in. The header cannot change behind the screen.
    func refreshCounts() async {
        guard case .loaded(let header) = header else { return }
        async let counts: Void = loadCounts(for: header.userId)
        async let clips: Void = loadClips(for: header.userId)
        _ = await (counts, clips)
    }

    /// A failed read keeps whatever counts were already shown. The request
    /// count travels with the follow counts: approving a request changes both.
    private func loadCounts(for userId: String) async {
        do {
            if let loaded = try await publicProfileLoader.profile(for: userId) {
                publicProfile = loaded
            }
        } catch {
            print("❌ Profile counts failed: \(error)")
        }
        do {
            pendingRequestCount = try await requestCountLoader.pendingRequestCount()
        } catch {
            print("❌ Follow request count failed: \(error)")
        }
    }

    /// Highlights and clips load independently; either failing leaves its own
    /// section empty and the rest of the profile intact.
    private func loadContent(for userId: String) async {
        async let highlights: Void = loadHighlights(for: userId)
        async let clips: Void = loadClips(for: userId)
        _ = await (highlights, clips)
    }

    private func loadHighlights(for userId: String) async {
        do {
            highlights = try await highlightsLoader.highlights(for: userId)
        } catch {
            print("❌ Profile highlights failed: \(error)")
        }
    }

    private func loadClips(for userId: String) async {
        do {
            clips = try await clipsLoader.clips(of: userId, limit: Self.clipLimit)
        } catch {
            print("❌ Profile clips failed: \(error)")
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
