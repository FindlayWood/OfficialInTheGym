//
//  PerformanceKitComposition.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import UIKit
import PerformanceKit


class PerformanceKitComposition {

    /// The PERFORMANCE tab. Player tab bar only. See `PERFORMANCE_PLAN.md`.
    ///
    /// **The legacy tools are reached through `PerformanceHomeCoordinator`**,
    /// built here on the tab's own stack and never `start()`ed: its `start()`
    /// presents the legacy intro modally, which is the coach-side and legacy
    /// callers' path. Its `modalNavigationController` is simply the stack its
    /// flow methods push onto, so pointing it at this tab is all the tab needs.
    /// Each tool comes off this switch as it moves into PerformanceKit.
    @MainActor
    func composeCombination(_ navigationController: UINavigationController, purchaseManager: PurchaseManager) {

        let user = UserDefaults.currentUser

        // MARK: - Pro

        let proAccess: PerformanceProAccess = PurchaseManagerPerformanceProAccess(purchaseManager: purchaseManager)

        // MARK: - Router

        let router = PerformanceKitRouter(
            navigationController: navigationController,
            proAccess: proAccess,
            currentUserId: user.uid,
            athleteId: user.uid
        )

        router.onShowPaywall = { [weak navigationController] in
            let vc = PremiumAccountViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.viewModel = PremiumAccountViewModel(purchaseManager: purchaseManager)
            navigationController?.present(vc, animated: true)
        }

        // MARK: - Legacy tools

        let legacyTools = PerformanceHomeCoordinator(
            navigationController: navigationController,
            user: user,
            subscriptionManager: purchaseManager
        )
        legacyTools.modalNavigationController = navigationController

        router.onOpenLegacyTool = { tool in
            switch tool {
            case .matchTracker: legacyTools.showMatchTracker()
            case .practiceTracker: legacyTools.showPracticeTracker()
            case .workload: legacyTools.showWorkload()
            case .verticalJump: legacyTools.showVerticalJump()
            case .journal: legacyTools.showJournalHome()
            }
        }

        router.start()
    }
}
