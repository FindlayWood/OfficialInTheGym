//
//  PerformanceHomeCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/07/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

/// The Performance Center tools that have not moved into PerformanceKit yet.
///
/// It used to be Performance Center itself: `start()` presented the legacy
/// intro screen full screen, or the paywall. That screen is now PerformanceKit's
/// home, and every way in goes through `PerformanceKitComposition`. What is left
/// here are the flow methods `PerformanceKitRouter.onOpenLegacyTool` calls,
/// which push a tool onto the router's own stack. **Each method goes as its
/// tool moves** (`PERFORMANCE_PLAN.md`), and then this type goes.
///
/// No longer a `Coordinator`, since it has nothing to `start()`. The navigation
/// controller is weak because the router that owns this object is reached from
/// that navigation controller's root screen.
final class PerformanceHomeCoordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = [Coordinator]()
    private weak var navigationController: UINavigationController?
    var user: Users
    var subscriptionManager: PurchaseManager
    // MARK: - Initializer
    init(navigationController: UINavigationController, user: Users, subscriptionManager: PurchaseManager) {
        self.navigationController = navigationController
        self.user = user
        self.subscriptionManager = subscriptionManager
    }
}
// MARK: - Flow
extension PerformanceHomeCoordinator {
    func showWorkload() {
        let vc = PerformanceMonitorViewController()
        vc.viewModel.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    func showWellness() {
        let vc = WellnessMainViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    func showTrainingStatus() {
        let vc = TrainingStatusMainViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    func showCMJ() {
        guard let navigationController else { return }
        let child = CMJCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
    }
    func showInjuryTracker() {
        let vc = InjuryTrackerViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
