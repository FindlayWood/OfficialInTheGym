//
//  CurrentUserProfileDetailsWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation
import ProfileKit

/// Writes the display name and bio onto the cached `UserDefaults.currentUser`,
/// which the profile header and most legacy screens read without a network
/// call. Without it an edit would not show anywhere until the next launch
/// refetched the user.
struct CurrentUserProfileDetailsWriter: ProfileDetailsWriter {

    func save(_ details: ProfileDetails) async throws {
        var user = UserDefaults.currentUser
        user.displayName = details.displayName
        user.bio = details.bio
        UserDefaults.currentUser = user
    }
}
