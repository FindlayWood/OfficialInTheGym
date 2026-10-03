//
//  AppSignOut.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation

/// Everything signing out involves, in one place. It clears the user's FCM
/// token so pushes stop, forgets the cached `currentUser`, signs out of
/// Firebase Auth, posts `signOut` (which returns the app to the welcome
/// screen), and empties the like and clip caches.
///
/// This was the body of `SettingsViewModel.logout()`. It moved here when the
/// PROFILE tab gained its own settings, because two copies of a sign-out
/// sequence are two lists that drift: the first one to forget a cache leaks
/// the previous user's data into the next session. **The legacy settings and
/// ProfileKit both call this. Do not re-inline it.**
///
/// The order matters. The FCM document is addressed by the uid, so it is
/// written before `currentUser` is forgotten, and the token write is the one
/// step allowed to fail the whole sign-out. A user left signed in can try
/// again, but a user signed out with a live token keeps receiving another
/// account's notifications.
struct AppSignOut {

    var authService: AuthManagerService = FirebaseAuthManager.shared
    var firestoreService: FirestoreService = FirestoreManager.shared

    func signOut() async throws {
        let fcmTokenModel = FCMTokenModel(fcmToken: nil, tokenUpdatedDate: .now)
        try await firestoreService.upload(dataPoints: ["FCMTokens/\(UserDefaults.currentUser.uid)": fcmTokenModel])
        try await MainActor.run {
            UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.currentUser.rawValue)
            try authService.signout()
            NotificationCenter.default.post(name: Notification.signOut, object: nil)
            LikeCache.shared.removeAll()
            ClipCache.shared.removeAll()
        }
    }
}
