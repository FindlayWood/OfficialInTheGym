//
//  CoachProfileMoreCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class CoachProfileMoreCoordinator: Coordinator {
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var subscriptionManager: PurchaseManager
    // MARK: - Initializer
    init(navigationController: UINavigationController, subscriptionManager: PurchaseManager) {
        self.navigationController = navigationController
        self.subscriptionManager = subscriptionManager
    }
    // MARK: - Start
    func start() {
         let vc = CoachProfileMoreViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.coordinator = self
        vc.viewModel = CoachProfileMoreViewModel(purchaseManager: subscriptionManager)
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Flow
extension CoachProfileMoreCoordinator {
    func editProfile() {
        let child = EditProfileCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
    }
    func showMySubscriptions() {
        navigationController.present(ProPaywallViewController.modal(purchaseManager: subscriptionManager), animated: true)
    }
    func showMyMeasurements() {
        let vc = MyMeasurementsViewController()
        vc.modalPresentationStyle = .fullScreen
        navigationController.present(vc, animated: true)
    }
    func showMyWorkouts() {
        let child = CoachWorkoutsCoordinator(navigationController: navigationController, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
    func exerciseStats() {
        let vc = DisplayExerciseStatsViewController()
        self.navigationController.pushViewController(vc, animated: true)
    }
    func myWorkoutStats() {
        let vc = MyWorkoutStatsViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    /// Unreachable: this coordinator is never built. It opens Performance
    /// Center, the legacy Workload screen it used to push having been retired.
    func showPerformanceMonitor(for user: Users) {
        MainActor.assumeIsolated {
            PerformanceKitComposition().presentModally(from: navigationController, athlete: user, purchaseManager: subscriptionManager)
        }
    }
    /// Unreachable: this coordinator is never built, and no row sends
    /// `.measureJump`. It opens Performance Center, where Vertical Jump lives
    /// now, rather than the jump camera, which moved into PerformanceKit.
    func jumpMeasure() {
        MainActor.assumeIsolated {
            PerformanceKitComposition().presentModally(from: navigationController, athlete: UserDefaults.currentUser, purchaseManager: subscriptionManager)
        }
    }
    func breathWork() {
        let vc = MethodSelectionViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    func settings() {
        let vc = SettingsViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
