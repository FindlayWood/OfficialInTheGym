//
//  ProfileActionState.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import Foundation

/// The state of a one-shot action on the settings screen, such as restoring
/// purchases or sending a reset email.
///
/// Both used to be fire-and-forget. The legacy settings fired the reset into a
/// `Task` and reported only through an alert, so the row itself never showed
/// that anything was happening. That is the pattern `VerifyEmailResendState`
/// replaced on the verify screen, and for the same reason: people tap again, and
/// repeated reset emails are what Firebase rate-limits. Each row now shows that
/// the action is in flight, that it worked, or that it failed.
enum ProfileActionState: Equatable {
    case idle
    case working
    case succeeded
    case failed

    var isWorking: Bool { self == .working }
}
