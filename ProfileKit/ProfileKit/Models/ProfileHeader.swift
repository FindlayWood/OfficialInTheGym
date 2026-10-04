//
//  ProfileHeader.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import Foundation

/// Who a profile belongs to: the identity half of the screen, everything above
/// the sections.
///
/// ProfileKit defines its own model rather than taking the app's `Users`:
/// `Users` carries the email, the account type and the legacy RTDB paths, and is
/// decoded from two stores. This holds only what a profile shows. From step 2 of
/// `PROFILE_PLAN.md` it is answered from `Profiles/{uid}`, the public
/// projection, and never from `Users/{uid}`. A type that only ever held these
/// fields can make that move without anything on screen changing.
///
/// **Premium is not here.** It is known only on the device (RevenueCat), so it
/// can be true for the signed-in user and nobody else. See `ProfileStamp`.
public struct ProfileHeader: Equatable, Sendable {
    public let userId: String
    public let displayName: String
    public let username: String
    public let bio: String
    public let isVerified: Bool
    public let isElite: Bool

    public init(
        userId: String,
        displayName: String,
        username: String,
        bio: String,
        isVerified: Bool,
        isElite: Bool
    ) {
        self.userId = userId
        self.displayName = displayName
        self.username = username
        self.bio = bio
        self.isVerified = isVerified
        self.isElite = isElite
    }
}
