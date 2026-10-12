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
    @MainActor
    func composeCombination(_ navigationController: UINavigationController, purchaseManager: PurchaseManager) {
        let router = makeRouter(navigationController, athlete: UserDefaults.currentUser, purchaseManager: purchaseManager)
        router.start()
    }

    /// Performance Center presented full screen over `presenter`, for the
    /// legacy ways in: a coach's athlete page (`athlete` is the athlete), the
    /// old "More" menu and the timeline (`athlete` is the signed-in user). The
    /// same root the tab shows, with a Dismiss button.
    @MainActor
    func presentModally(from presenter: UINavigationController, athlete: Users, purchaseManager: PurchaseManager) {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        let router = makeRouter(navigationController, athlete: athlete, purchaseManager: purchaseManager)
        router.onDismiss = { [weak presenter] in presenter?.dismiss(animated: true) }
        router.start()
        presenter.present(navigationController, animated: true)
    }

    /// A fully wired router on any navigation controller, **without** `start()`.
    @MainActor
    private func makeRouter(_ navigationController: UINavigationController, athlete: Users, purchaseManager: PurchaseManager) -> PerformanceKitRouter {

        // MARK: - Pro
        // The whole tab is pro. Emulator builds unlock it through
        // `EmulatorPurchaseManager`, the same switch the paywall uses.

        let proAccess: PerformanceProAccess = PurchaseManagerProAccess(purchaseManager: purchaseManager)

        // MARK: - Jump tests
        // The athlete's sessions, with Vertical Jump's pre-engine history read
        // alongside. Only the athlete can record one (the router offers
        // recording on your own Performance Center only).

        let jumpSessionsLoader: JumpTestSessionsLoader = CurrentAndLegacyJumpTestSessionsLoader(
            current: FirestoreJumpTestSessionsLoader(userId: athlete.uid),
            legacy: LegacyVerticalJumpSessionsLoader(userId: athlete.uid)
        )

        let jumpSessionWriter: JumpTestSessionWriter = FirestoreJumpTestSessionWriter(userId: athlete.uid)

        let bodyMassLoader: BodyMassLoader = FirestoreBodyMassLoader(userId: athlete.uid)

        // MARK: - Balance

        let balanceSessionsLoader: BalanceSessionsLoader = FirestoreBalanceSessionsLoader(userId: athlete.uid)

        let balanceSessionWriter: BalanceSessionWriter = FirestoreBalanceSessionWriter(userId: athlete.uid)

        // MARK: - Router

        let router = PerformanceKitRouter(
            navigationController: navigationController,
            proAccess: proAccess,
            jumpSessionsLoader: jumpSessionsLoader,
            jumpSessionWriter: jumpSessionWriter,
            bodyMassLoader: bodyMassLoader,
            balanceSessionsLoader: balanceSessionsLoader,
            balanceSessionWriter: balanceSessionWriter,
            currentUserId: UserDefaults.currentUser.uid,
            athleteId: athlete.uid
        )

        router.onShowPaywall = { [weak navigationController] in
            navigationController?.present(ProPaywallViewController.modal(purchaseManager: purchaseManager), animated: true)
        }

        #if EMULATOR
        router.onUnlockForTesting = { (purchaseManager as? EmulatorPurchaseManager)?.unlockForTesting() }
        #endif

        return router
    }
}
