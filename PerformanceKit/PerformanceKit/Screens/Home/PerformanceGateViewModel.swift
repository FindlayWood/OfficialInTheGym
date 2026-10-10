//
//  PerformanceGateViewModel.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Combine
import Foundation

/// Whether the PERFORMANCE tab shows its content or the locked screen.
///
/// **The whole tab is pro**, and the check is made **every time the tab
/// appears** (`refresh()`), never once when it is built. The tab is built at
/// launch for every user, so a value captured then would keep a new subscriber
/// locked out until relaunch. The paywall is presented full screen, so
/// dismissing it makes the tab appear again, which is what re-checks it.
///
/// `canUnlockForTesting` is true only in emulator builds, where the composition
/// root sets the router's `onUnlockForTesting`. It is never true in a build
/// that can ship.
@MainActor
final class PerformanceGateViewModel: ObservableObject {

    @Published private(set) var isUnlocked: Bool

    var onShowPaywall: (() -> Void)?
    var onUnlockForTesting: (() -> Void)?

    private let proAccess: PerformanceProAccess

    init(proAccess: PerformanceProAccess) {
        self.proAccess = proAccess
        self.isUnlocked = proAccess.hasUnlockedPro
    }

    var canUnlockForTesting: Bool {
        onUnlockForTesting != nil
    }

    func refresh() {
        let unlocked = proAccess.hasUnlockedPro
        if unlocked != isUnlocked { isUnlocked = unlocked }
    }

    func showPaywall() {
        onShowPaywall?()
    }

    func unlockForTesting() {
        onUnlockForTesting?()
        refresh()
    }
}
