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
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    // MARK: - Start
    func start() {
         let vc = CoachProfileMoreViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.coordinator = self
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
        let vc = PremiumAccountViewController()
        navigationController.present(vc, animated: true)
    }
    func showMyMeasurements() {
        let vc = MyMeasurementsViewController()
        vc.modalPresentationStyle = .fullScreen
        navigationController.present(vc, animated: true)
    }
    func showMyWorkouts() {
        let child = CoachWorkoutsCoordinator(navigationController: navigationController)
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
    func showPerformanceMonitor(for user: Users) {
        let vc = PerformanceMonitorViewController()
        vc.viewModel.user = user
        navigationController.pushViewController(vc, animated: true)
    }
    func jumpMeasure() {
        let vc = JumpMeasuringViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.modalPresentationStyle = .fullScreen
        navigationController.present(vc, animated: true)
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
