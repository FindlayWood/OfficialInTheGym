//
//  PerformanceHomeCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/07/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

/// Performance Center, opened two ways.
///
/// **As the player tab bar's middle tab** (`startAsTab()`). The intro screen is
/// the root of the tab's own navigation controller, so every tool pushes onto
/// that stack, and there is no Dismiss button, since a tab has nothing to
/// dismiss to.
///
/// **As a full-screen modal** (`start()`), which is how it was always opened and
/// how the coach-side `PlayerDetailCoordinator`, the legacy
/// `PlayerProfileMoreCoordinator` and `TimelineCoordinator` still open it. A
/// non-pro user gets the paywall in place of the modal.
///
/// **The tab is built for every user, so the tab gates pro at tap time**, in
/// `requirePro()`. Gating when the tab is built would leave a paywall sitting in
/// the tab bar after the user subscribes, until relaunch. The modal path never
/// reaches the intro screen without pro, so the check costs it nothing.
class PerformanceHomeCoordinator: Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    var modalNavigationController: UINavigationController!
    var user: Users
    var subscriptionManager: PurchaseManager
    // MARK: - Initializer
    init(navigationController: UINavigationController, user: Users, subscriptionManager: PurchaseManager) {
        self.navigationController = navigationController
        self.user = user
        self.subscriptionManager = subscriptionManager
    }
    // MARK: - Start
    /// The player tab bar's PERFORMANCE tab: the intro screen as the root of
    /// `navigationController`, which then doubles as the stack every tool
    /// pushes onto.
    func startAsTab() {
        let vc = PerformanceIntroViewController()
        vc.coordinator = self
        vc.viewModel.user = user
        vc.showsDismissButton = false
        modalNavigationController = navigationController
        navigationController.setViewControllers([vc], animated: false)
    }
    func start() {
        if subscriptionManager.hasUnlockedPro {
            let vc = PerformanceIntroViewController()
            vc.coordinator = self
            vc.viewModel.user = user
            modalNavigationController = UINavigationController(rootViewController: vc)
            modalNavigationController.modalPresentationStyle = .fullScreen
            navigationController.present(modalNavigationController, animated: true)
        } else {
            let vc = PremiumAccountViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.viewModel = PremiumAccountViewModel(purchaseManager: subscriptionManager)
            navigationController.present(vc, animated: true)
        }

    }
    func dismiss() {
        navigationController.dismiss(animated: true)
    }
    /// True when the user has pro. Otherwise presents the paywall and returns
    /// false. See the type's comment for why the tab checks here and not when
    /// it is built.
    func requirePro() -> Bool {
        guard !subscriptionManager.hasUnlockedPro else { return true }
        let vc = PremiumAccountViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.viewModel = PremiumAccountViewModel(purchaseManager: subscriptionManager)
        navigationController.present(vc, animated: true)
        return false
    }
}
// MARK: - Flow
extension PerformanceHomeCoordinator {
    func showMatchTracker() {
        let child = MatchTrackerCoordinator(navigationController: modalNavigationController)
        childCoordinators.append(child)
        child.start()
    }
    func showPracticeTracker() {
        let child = PracticeTrackerCoordinator(navigationController: modalNavigationController)
        childCoordinators.append(child)
        child.start()
    }
    func showWorkload() {
        let vc = PerformanceMonitorViewController()
        vc.viewModel.user = user
        modalNavigationController.pushViewController(vc, animated: true)
    }
    func showWellness() {
        let vc = WellnessMainViewController()
        modalNavigationController.pushViewController(vc, animated: true)
    }
    func showTrainingStatus() {
        let vc = TrainingStatusMainViewController()
        modalNavigationController.pushViewController(vc, animated: true)
    }
    func showVerticalJump() {
        let child = JumpCoordinator(navigationController: modalNavigationController, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
    func showCMJ() {
        let child = CMJCoordinator(navigationController: modalNavigationController)
        childCoordinators.append(child)
        child.start()
    }
    func showInjuryTracker() {
        let vc = InjuryTrackerViewController()
        modalNavigationController.pushViewController(vc, animated: true)
    }
    func showJournalHome() {
        let vc = JournalHomeViewController()
        modalNavigationController.pushViewController(vc, animated: true)
    }
}
