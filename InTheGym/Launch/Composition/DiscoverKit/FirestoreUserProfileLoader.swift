//
//  FirestoreUserProfileLoader.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import Foundation

/// DISCOVER's author names, read from `Profiles/{uid}` through
/// `ProfileNamesReader`, which holds the batched query ProfileKit's follow lists
/// share.
///
/// **`Profiles`, never `Users`.** This used to query other people's
/// `Users/{uid}` documents, and Firestore rules cannot hide single fields, so
/// whatever let it through let any signed-in user read anyone's email.
/// `Profiles/{uid}` is the public projection the `syncProfile` Cloud Function
/// writes, holding only what others may see (`PROFILE_PLAN.md` step 2), and the
/// rules close `Users/{uid}` to its owner once every reader has moved here.
struct FirestoreUserProfileLoader: UserProfileLoader {

    var reader = ProfileNamesReader()

    func profiles(for userIds: Set<String>) async throws -> [String: DiscoverUserProfile] {
        try await reader.names(for: userIds).mapValues {
            DiscoverUserProfile(userId: $0.userId, username: $0.username, displayName: $0.displayName)
        }
    }
}
