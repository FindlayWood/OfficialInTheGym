//
//  EmulatorUnlockPerformanceProAccess.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import PerformanceKit

#if EMULATOR
/// Pro for testing the PERFORMANCE tab against the emulator, where nothing can
/// be bought. The locked screen still shows; its "Unlock for testing" button
/// calls `unlock()`, and from then on this answers pro for the rest of the
/// session. In memory only, so a relaunch is locked again.
///
/// **Compiled only with `-D EMULATOR`** (the app's Emulator configuration,
/// used by the InTheGym-EM scheme), which also points Firebase at localhost,
/// so a build that has it cannot talk to production. It wraps the real check
/// rather than replacing it: an account that does have pro still reads as pro.
final class EmulatorUnlockPerformanceProAccess: PerformanceProAccess {

    // MARK: - Properties
    /// Shared by every router the composition builds, the tab and any
    /// presented Performance Center, so unlocking once unlocks them all.
    private static var isUnlocked = false
    private let wrapped: PerformanceProAccess

    // MARK: - Initializer
    init(wrapping wrapped: PerformanceProAccess) {
        self.wrapped = wrapped
    }

    var hasUnlockedPro: Bool { Self.isUnlocked || wrapped.hasUnlockedPro }

    static func unlock() {
        isUnlocked = true
    }
}
#endif
