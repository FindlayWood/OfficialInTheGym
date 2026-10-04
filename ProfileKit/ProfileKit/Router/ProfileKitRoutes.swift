//
//  ProfileKitRoutes.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import UIKit

/// Every screen ProfileKit can show. Later steps of `PROFILE_PLAN.md` add edit
/// profile, followers, requests and other users' profiles here.
enum ProfileKitRoutes {
    case myProfile
    case settings
    case bodyMeasurements
    case followList(FollowListKind, userId: String)
    case followRequests
    case userProfile(userId: String)
    case search
    case deleteAccount
    case editHighlights(pinned: [String], onSaved: (ProfileHighlights) -> Void)
    /// Carries what the profile already holds, so the editor opens filled in
    /// without a second read.
    case editProfile(header: ProfileHeader, photo: UIImage?, onSaved: () -> Void)
}
