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
        DispatchQueue.main.async {
            if user.accountType == .coach {
                self.showLoggedInCoach()
            } else {
                self.showLoggedInPlayer()
            }
        }
    }
    
    func handleUserStateError(_ state: UserStateError) {
        DispatchQueue.main.async {
            switch state {
            case .noUser:
                self.showLogin()
            case .notVerified:
                self.showVerifyEmail()
            case .noAccount:
                self.showAccountCreation()
            }
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
        let _ = LoginComposition(navigationController: self.navigationController).loginKitInterface.compose()
    }
    
    func showVerifyEmail() {
        let vc = VerifyAccountViewController()
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func showAccountCreation() {
//        let _ = AccountCreationComposition(navigationController: navigationController, email: email, uid: uid).accountCreationKitInterface.compose()
    }
    
    func showLoggedInPlayer() {
        let mainPlayerCoordinator = MainPlayerCoordinator(navigationController: self.navigationController)
        mainPlayerCoordinator.start()
    }
    
    func showLoggedInCoach() {
        let mainCoachCoordinator = MainCoachCoordinator(navigationController: self.navigationController)
        mainCoachCoordinator.start()
    }
}
