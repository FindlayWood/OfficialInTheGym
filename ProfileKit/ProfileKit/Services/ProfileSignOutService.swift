//
//  ProfileSignOutService.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import Foundation

/// Signs the user out.
///
/// The app answers it with `AppSignOut`, the one definition of everything signing
/// out involves (FCM token, cached user, caches, the `signOut` notification that
/// returns to the welcome screen). ProfileKit only asks for it to happen.
public protocol ProfileSignOutService {
    func signOut() async throws
}
