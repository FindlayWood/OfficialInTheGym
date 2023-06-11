//
//  BaseControllerCoordinator.swift
//  InTheGym
//
//  Created by Findlay-Personal on 09/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class BaseController {
    
    var navigationController: UINavigationController
    var userService: UserService?
    var observerService: ObserveUserService?
    var cacheSaver: CacheUserSaver?
    var baseFlow: BaseFlow?
    
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
        cacheSaver?.save(user)
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
            case .noAccount(let email, let uid):
                self.showAccountCreation(email: email, uid: uid)
            }
        }
       
    }
    
    func observe() {
        observerService?.observeChange(completion: { [weak self] result in
            switch result {
            case .success(let userModel):
                if UserDefaults.currentUser == Users.nilUser {
                    self?.handleUser(userModel)
                } else {
                    self?.cacheSaver?.save(userModel)
                }
            case .failure(let error):
                self?.handleUserStateError(error)
            }
        })
    }
    
    func showLogin() {
        baseFlow?.showLogin()
    }
    
    func showVerifyEmail() {
        baseFlow?.showVerifyEmail()
    }
    
    func showAccountCreation(email: String, uid: String) {
        baseFlow?.showAccountCreation(email: email, uid: uid)
    }
    
    func showLoggedInPlayer() {
        baseFlow?.showLoggedInPlayer()
    }
    
    func showLoggedInCoach() {
        baseFlow?.showLoggedInCoach()
    }
}


protocol BaseFlow {
    func showLogin()
    func showLoggedInPlayer()
    func showLoggedInCoach()
    func showVerifyEmail()
    func showAccountCreation(email: String, uid: String)
}

struct BasicBaseFlow: BaseFlow {
    var navigationController: UINavigationController
    
    func showLogin() {
        LoginComposition(navigationController: navigationController).loginKitInterface.compose()
    }
    
    func showLoggedInPlayer() {
        let mainPlayerCoordinator = MainPlayerCoordinator(navigationController: navigationController)
        mainPlayerCoordinator.start()
    }
    
    func showLoggedInCoach() {
        let mainCoachCoordinator = MainCoachCoordinator(navigationController: self.navigationController)
        mainCoachCoordinator.start()
    }
    
    func showVerifyEmail() {
        let vc = VerifyAccountViewController()
        vc.viewModel.baseFlow = self
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func showAccountCreation(email: String, uid: String) {
        AccountCreationComposition(navigationController: navigationController, email: email, uid: uid).accountCreationKitInterface.compose()
    }
}

