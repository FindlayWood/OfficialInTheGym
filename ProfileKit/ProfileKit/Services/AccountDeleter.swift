//
//  AccountDeleter.swift
//  ProfileKit
//
//  Created by Findlay Wood on 04/10/2026.
//
import Foundation

/// Deletes the signed-in user's account for good (App Store guideline
/// 5.1.1(v), `PROFILE_PLAN.md` step 10).
///
/// The password is asked for again first. A phone left unlocked must not be
/// able to delete its owner's account in two taps, and confirming the
/// password is also proof the right person is holding it. The adapter
/// re-authenticates, calls the `deleteAccount` function, wipes this device's
/// local copies, and ends the session, which returns the app to the welcome
/// screen. On success there is nothing left for ProfileKit to show.
public protocol AccountDeleter {
    func deleteAccount(password: String) async throws
}

/// Why a deletion did not happen, as far as the screen needs to tell them
/// apart. Each needs a different thing from the user.
public enum AccountDeletionError: Error, Equatable {
    /// The password was wrong. Nothing was deleted; try again.
    case wrongPassword
    /// Too many wrong passwords; Firebase has paused attempts for a while.
    case tooManyAttempts
    /// Anything else, network included. Deletion is safe to retry. The server
    /// finishes whatever a failed attempt left.
    case failed
}
