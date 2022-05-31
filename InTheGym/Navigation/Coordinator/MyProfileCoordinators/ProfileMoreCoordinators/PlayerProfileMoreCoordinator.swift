//
//  PlayerProfileMoreCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class PlayerProfileMoreCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
         let vc = PlayerProfileMoreViewController()
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
extension PlayerProfileMoreCoordinator {
    func editProfile() {
        let child = EditProfileCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
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
    func userSelected(_ user: Users) {
        let child = UserProfileCoordinator(navigationController: navigationController, user: user)
        childCoordinators.append(child)
        child.start()
    }
}
