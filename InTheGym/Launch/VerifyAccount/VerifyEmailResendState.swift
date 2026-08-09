//
//  VerifyEmailResendState.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/08/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// What the resend button is doing.
///
/// Tapping resend used to change nothing on screen at all — the send was fired into a `Task` and the
/// result printed — so the only way to find out whether anything happened was to go and look in a
/// mail client. People tap again, and Firebase rate-limits repeated verification sends, so tapping
/// again is also the one thing that makes it worse.
enum VerifyEmailResendState: Equatable {
    case idle
    case sending
    /// Sent, and on cooldown for this many more seconds.
    case sent(secondsRemaining: Int)
    case failed
}
