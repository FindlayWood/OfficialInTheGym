//
//  CurrentUserMyProfileLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation
import ProfileKit

/// Answers the signed-in user's own header from `UserDefaults.currentUser`,
/// the `Users` document the launch path fetched from Firestore. No network.
///
/// Read on every `load()`, not once at composition. The tab outlives any one
/// visit, and a pull-to-refresh should see a newer cached user.
///
/// **Step 1 only.** The bio here is Firestore's `Users.bio`, but the legacy
/// Edit Profile writes RTDB `users/{uid}/profileBio`, so a bio edited there
/// does not show here. Step 3 of `PROFILE_PLAN.md` moves editing onto
/// Firestore, and step 2 moves this read to `Profiles/{uid}`.
struct CurrentUserMyProfileLoader: MyProfileLoader {

    func load() async throws -> ProfileHeader {
        let user = UserDefaults.currentUser
        return ProfileHeader(
            userId: user.uid,
            displayName: user.displayName,
            username: user.username,
            bio: user.bio,
            isVerified: user.verifiedAccount,
            isElite: user.eliteAccount
        )
    }
}
