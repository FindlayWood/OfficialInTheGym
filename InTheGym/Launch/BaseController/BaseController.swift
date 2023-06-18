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
    var cacheSaver: CacheUserSaver?
    var baseFlow: BaseFlow?
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController.navigationBar.shadowImage = UIImage()
        self.navigationController.navigationBar.tintColor = .white
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
