//
//  MainCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController.navigationBar.shadowImage = UIImage()
        self.navigationController.navigationBar.tintColor = .white
    }
    
    func start() {
        let vc = LaunchPageViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func notLoggedIn() {
        let vc = ViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func login() {
        let vc = LoginViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func signUpStepOne() {
        let vc = PlayerOrCoachViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func signUpStepTwo(isAdmin: Bool) {
        let vc = SignUpViewController.instantiate()
        vc.coordinator = self
        vc.admin = isAdmin
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    func coordinateToTabBar() {
        let tabBar = TabBarCoordinator(navigationController: navigationController)
        coordinate(to: tabBar)
    }
    
    func forgotPassword() {
        let vc = ResetPasswordViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
}
