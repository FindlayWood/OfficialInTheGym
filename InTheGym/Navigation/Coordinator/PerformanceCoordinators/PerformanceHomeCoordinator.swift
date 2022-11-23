//
//  PerformanceHomeCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/07/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PerformanceHomeCoordinator: Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    var modalNavigationController: UINavigationController!
    var user: Users
    // MARK: - Initializer
    init(navigationController: UINavigationController, user: Users) {
        self.navigationController = navigationController
        self.user = user
    }
    // MARK: - Start
    func start() {
        if SubscriptionManager.shared.isSubscribed {
            let vc = PerformanceIntroViewController()
            vc.coordinator = self
            vc.viewModel.user = user
            modalNavigationController = UINavigationController(rootViewController: vc)
            modalNavigationController.modalPresentationStyle = .fullScreen
            navigationController.present(modalNavigationController, animated: true)
        } else {
            let vc = PremiumAccountViewController()
            navigationController.present(vc, animated: true)
        }

    }
    func dismiss() {
        navigationController.dismiss(animated: true)
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
        let child = JumpCoordinator(navigationController: modalNavigationController)
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
