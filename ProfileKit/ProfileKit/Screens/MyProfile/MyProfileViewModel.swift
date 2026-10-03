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
/// Step 1 of `PROFILE_PLAN.md` is the header only: photo, name, @username,
/// stamps and bio. The plan's sections (highlights, clips) and the follower
/// counts arrive in later steps. **The counts are deliberately absent rather
/// than drawn as placeholders**: a "0 followers" before the follows model exists
/// would be a claim, not a placeholder.
///
/// The header and the photo load independently. The photo is a second network
/// read (Storage) that can fail or simply not exist, and neither case may hold
/// the name back or turn the screen into an error. A failed photo leaves the
/// placeholder avatar, which is also what "no photo set" looks like.
@MainActor
final class MyProfileViewModel: ObservableObject {

    @Published private(set) var header: ProfileLoadState<ProfileHeader> = .loading
    @Published private(set) var photo: UIImage?

    private let profileLoader: MyProfileLoader
    private let photoLoader: ProfilePhotoLoader
    private let subscription: ProfileSubscriptionService

    var onOpenSettings: (() -> Void)?

    init(
        profileLoader: MyProfileLoader,
        photoLoader: ProfilePhotoLoader,
        subscription: ProfileSubscriptionService
    ) {
        self.profileLoader = profileLoader
        self.photoLoader = photoLoader
        self.subscription = subscription
    }

    /// Premium is passed in because this is your own profile. See `ProfileStamp`.
    var stamps: [ProfileStamp] {
        guard case .loaded(let header) = header else { return [] }
        return ProfileStamp.stamps(for: header, hasUnlockedPro: subscription.hasUnlockedPro)
    }

    func load() async {
        // A refresh keeps the header on screen. Only a first load shows the skeleton.
        if case .failed = header { header = .loading }
        do {
            let loaded = try await profileLoader.load()
            header = .loaded(loaded)
            await loadPhoto(for: loaded.userId)
        } catch {
            print("❌ Profile header failed: \(error)")
            if case .loaded = header { return }
            header = .failed
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
