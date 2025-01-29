//
//  PlayerProfileMoreCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PlayerProfileMoreCoordinator: Coordinator {
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
         let vc = PlayerProfileMoreViewController()
        vc.coordinator = self
        vc.viewModel = .init(purchaseManager: subscriptionManager)
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Flow
extension PlayerProfileMoreCoordinator {
    func editProfile() {
        let child = EditProfileCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
    }
    func showMySubscriptions() {
        let vc = PremiumAccountViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.viewModel = PremiumAccountViewModel(purchaseManager: subscriptionManager)
        navigationController.present(vc, animated: true)
    }
    func showMyMeasurements() {
        let vc = MyMeasurementsViewController()
        vc.modalPresentationStyle = .fullScreen
        navigationController.present(vc, animated: true)
    }
    func myCoaches() {
        let vc = COACHESViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    func myRequests() {
        let vc = RequestsViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    func exerciseStats() {
        let vc = DisplayExerciseStatsViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    func myWorkoutStats() {
        let vc = MyWorkoutStatsViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    func showPerformanceMonitor(for user: Users) {
        let child = PerformanceHomeCoordinator(navigationController: navigationController, user: user, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
    func jumpMeasure() {
        let child = JumpCoordinator(navigationController: navigationController, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
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
    func userSelected(_ user: Users) {
        let child = UserProfileCoordinator(navigationController: navigationController, user: user, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
}
