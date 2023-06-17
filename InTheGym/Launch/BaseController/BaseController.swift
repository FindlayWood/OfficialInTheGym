//
//  BaseControllerCoordinator.swift
//  InTheGym
//
//  Created by Findlay-Personal on 09/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Combine
import Foundation
import UIKit

class BaseController {
    
    private var subscriptions = Set<AnyCancellable>()
    
    var navigationController: UINavigationController
    var userService: UserLoader?
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
        NotificationCenter.default.publisher(for: Notification.signOut)
            .sink { [weak self] _ in
                self?.loadUser()
            }
            .store(in: &subscriptions)
    }
    
    func loadUser() {
        Task {
            guard let userResult = await userService?.loadUser() else { return }
            handleResult(userResult)
//            if let user = try? await userService?.loadUser() {
//                handleUser(user)
//            } else {
//                handleUserStateError(.noUser)
//            }
        }
    }
    
    func handleResult(_ result: Result<Users,UserStateError>) {
        switch result {
        case .success(let user):
            handleUser(user)
        case .failure(let error):
            handleUserStateError(error)
        }
    }
    
    func reloadUser() {
        Task {
            if let user = try? await userService?.loadUser().get() {
                cacheSaver?.save(user)
                DispatchQueue.main.async {
                    self.baseFlow?.showAccountCreated(for: user)
                }
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
    
//    func observe() {
//        observerService?.observeChange(completion: { [weak self] result in
//            switch result {
//            case .success(let userModel):
//                if UserDefaults.currentUser == Users.nilUser {
//                    self?.handleUser(userModel)
//                } else {
//                    self?.cacheSaver?.save(userModel)
//                }
//            case .failure(let error):
//                self?.handleUserStateError(error)
//            }
//        })
//    }
    
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
    func showAccountCreated(for user: Users)
}

struct BasicBaseFlow: BaseFlow {
    var navigationController: UINavigationController
    var accountCreatedCallback: () -> Void
    var userLoggedIn: () -> Void
    var userSignedOut: () -> Void
    
    func showLogin() {
        LoginComposition(navigationController: navigationController, completion: userLoggedIn).loginKitInterface.compose()
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
        vc.viewModel.signOutAction = userSignedOut
        vc.viewModel.baseFlow = self
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func showAccountCreation(email: String, uid: String) {
        AccountCreationComposition(navigationController: navigationController, email: email, uid: uid, completion: accountCreatedCallback, signOut: userSignedOut).accountCreationKitInterface.compose()
    }
    func showAccountCreated(for user: Users) {
        let vc = AccountCreatedViewController()
        vc.baseFlow = self
        vc.user = user
        navigationController.setViewControllers([vc], animated: true)
    }
}

