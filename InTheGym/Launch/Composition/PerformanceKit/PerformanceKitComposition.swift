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
    /// old "More" menu and the timeline (`athlete` is the signed-in user). They
    /// used to present the legacy intro screen; this is the same home the tab
    /// shows, with a Dismiss button.
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
    ///
    /// **The legacy tools are reached through `PerformanceHomeCoordinator`**,
    /// built on the router's own stack, so a tool that has not moved into
    /// PerformanceKit yet pushes onto the same stack the home screen is on.
    /// Each tool comes off this switch as it moves.
    @MainActor
    private func makeRouter(_ navigationController: UINavigationController, athlete: Users, purchaseManager: PurchaseManager) -> PerformanceKitRouter {

        // MARK: - Pro

        let proAccess: PerformanceProAccess = PurchaseManagerPerformanceProAccess(purchaseManager: purchaseManager)

        // MARK: - Journal
        // Owner-only: reachable only when the athlete is the signed-in user.

        let journalLoader: JournalEntriesLoader = FirestoreJournalEntriesLoader(userId: athlete.uid)

        let journalWriter: JournalEntryWriter = EntriesAndLatestJournalEntryWriter(
            entries: FirestoreJournalEntryWriter(userId: athlete.uid),
            latest: FirestoreLatestJournalEntryWriter(userId: athlete.uid)
        )

        // MARK: - Router

        let router = PerformanceKitRouter(
            navigationController: navigationController,
            proAccess: proAccess,
            journalLoader: journalLoader,
            journalWriter: journalWriter,
            currentUserId: UserDefaults.currentUser.uid,
            athleteId: athlete.uid
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
            user: athlete,
            subscriptionManager: purchaseManager
        )

        router.onOpenLegacyTool = { tool in
            switch tool {
            case .matchTracker: legacyTools.showMatchTracker()
            case .practiceTracker: legacyTools.showPracticeTracker()
            case .workload: legacyTools.showWorkload()
            case .verticalJump: legacyTools.showVerticalJump()
            case .journal: break // PerformanceKit's own; the router never hands it back
            }
        }

        return router
    }
}
