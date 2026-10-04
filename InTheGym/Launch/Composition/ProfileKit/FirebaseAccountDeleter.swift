//
//  FirebaseAccountDeleter.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation
import ProfileKit

/// ProfileKit's Delete Account, as four steps in an order that matters:
///
/// 1. **Re-authenticate.** A wrong password stops everything with nothing
///    touched.
/// 2. **Delete remotely** (`deleteAccount`). If this fails the user is still
///    signed in and can simply try again. The function finishes what a failed
///    attempt left, and the Auth user goes last, so there is no half-deleted
///    account nobody can reach.
/// 3. **Erase this device's copies.** Only once the server has confirmed. Wiping
///    first would lose unsynced data for a deletion that then failed.
/// 4. **End the session locally** (`AppSignOut.endLocalSession`), back to the
///    welcome screen.
struct FirebaseAccountDeleter: AccountDeleter {

    let userId: String
    var reauthenticator = FirebasePasswordReauthenticator()
    var remote = FunctionsAccountDeleter()
    var session = AppSignOut()

    func deleteAccount(password: String) async throws {
        try await reauthenticator.reauthenticate(password: password)
        do {
            try await remote.deleteRemoteAccount()
        } catch {
            print("❌ deleteAccount failed: \(error)")
            throw AccountDeletionError.failed
        }
        LocalUserDataEraser(userId: userId).erase()
        try? await MainActor.run { try session.endLocalSession() }
    }
}
