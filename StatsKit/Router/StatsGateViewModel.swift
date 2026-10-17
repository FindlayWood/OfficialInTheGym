//
//  StatsGateViewModel.swift
//  StatsKit
//
//  Created by Findlay Wood on 12/10/2026.
//

import Combine
import Foundation

/// Whether the STATS tab shows its content or the locked screen.
///
/// **The whole tab is pro**, checked **every time the tab appears** (`refresh()`), never once when
/// it is built — the same rule, for the same reason, as PerformanceKit's `PerformanceGateViewModel`.
/// The paywall is presented full screen, so closing it makes the tab appear again, and that is what
/// re-checks it. No testing unlock lives here: emulator builds unlock from the paywall itself, which
/// unlocks every tab at once.
@MainActor
final class StatsGateViewModel: ObservableObject {

    @Published private(set) var isUnlocked: Bool

    var onShowPaywall: (() -> Void)?

    private let proAccess: StatsProAccess

    init(proAccess: StatsProAccess) {
        self.proAccess = proAccess
        self.isUnlocked = proAccess.hasUnlockedPro
    }

    func refresh() {
        let unlocked = proAccess.hasUnlockedPro
        if unlocked != isUnlocked { isUnlocked = unlocked }
    }

    func showPaywall() {
        onShowPaywall?()
    }
}
