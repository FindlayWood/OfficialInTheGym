//
//  SignUpCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

/// sign up coordinator shows initial screen and controls login flow
class SignUpCoordinator: Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    // MARK: - Start
    func start() {
        let vc = ViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Flow
extension SignUpCoordinator {
    func login() {
        let vc = LoginViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    func signUpStepOne() {
        let vc = PlayerOrCoachViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    func signUpStepTwo(isAdmin: Bool) {
        let vc = SignUpViewController()
        vc.coordinator = self
        vc.admin = isAdmin
        navigationController.pushViewController(vc, animated: true)
    }
}
