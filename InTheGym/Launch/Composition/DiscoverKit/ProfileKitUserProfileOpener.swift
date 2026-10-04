//
//  ProfileKitUserProfileOpener.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import DiscoverKit
import ProfileKit

/// Answers DISCOVER's `UserProfileOpener` with ProfileKit's profile screen,
/// pushed onto DISCOVER's own navigation controller by a ProfileKit router
/// built on that stack (`ProfileKitComposition.makeRouter`). Back returns to
/// the workout, clip or comments the user came from, and anything opened from
/// the profile stays in DISCOVER's tab.
struct ProfileKitUserProfileOpener: UserProfileOpener {

    let router: ProfileKitRouter

    func openProfile(_ userId: String) {
        MainActor.assumeIsolated {
            router.showUserProfile(userId)
        }
    }
}
