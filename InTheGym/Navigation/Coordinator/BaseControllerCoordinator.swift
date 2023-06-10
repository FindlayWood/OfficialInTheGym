//
//  BaseControllerCoordinator.swift
//  InTheGym
//
//  Created by Findlay-Personal on 09/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class BaseControllerCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var userService: UserService?
    
    var observerService: ObserveUserService?
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController.navigationBar.shadowImage = UIImage()
        self.navigationController.navigationBar.tintColor = .white
    }
    
    deinit {
        print("this is gone!!! --------- ")
    }
    
    func start() {
        let vc = LaunchPageViewController()
        navigationController.setViewControllers([vc], animated: false)
        loadUser()
    }
    
    func loadUser() {
        Task {
            if let user = try? await userService?.loadUser() {
               handleUser(user)
                observe()
            } else {
                observe()
            }
        }
    }
    
    func handleUser(_ user: Users) {
        if user.accountType == .coach {
            showLoggedInCoach()
        } else {
            showLoggedInPlayer()
        }
    }
    
    func handleUserStateError(_ state: UserStateError) {
        switch state {
        case .noUser:
            showLogin()
        case .notVerified:
            showVerifyEmail()
        case .noAccount:
            showAccountCreation()
        }
    }
    
    func observe() {
        observerService?.observeChange(completion: { [weak self] result in
            switch result {
            case .success(let userModel):
                if UserDefaults.currentUser == Users.nilUser {
                    UserDefaults.currentUser = userModel
                    self?.handleUser(userModel)
                } else {
                    UserDefaults.currentUser = userModel
                }
            case .failure(let error):
                self?.handleUserStateError(error)
            }
        })
    }
    
    func showLogin() {
        DispatchQueue.main.async {
            let _ = LoginComposition(navigationController: self.navigationController).loginKitInterface.compose()
        }
    }
    
    func showVerifyEmail() {
        let vc = VerifyAccountViewController()
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func showAccountCreation() {
//        let _ = AccountCreationComposition(navigationController: navigationController, email: email, uid: uid).accountCreationKitInterface.compose()
    }
    
    func showLoggedInPlayer() {
        DispatchQueue.main.async {
            self.navigationController.dismiss(animated: true)
            let mainPlayerCoordinator = MainPlayerCoordinator(navigationController: self.navigationController)
            mainPlayerCoordinator.start()
        }
    }
    
    func showLoggedInCoach() {
        DispatchQueue.main.async {
            let mainCoachCoordinator = MainCoachCoordinator(navigationController: self.navigationController)
            mainCoachCoordinator.start()
        }
    }
}
