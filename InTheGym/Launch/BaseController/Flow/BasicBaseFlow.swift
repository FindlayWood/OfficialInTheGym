//
//  BasicBaseFlow.swift
//  InTheGym
//
//  Created by Findlay-Personal on 17/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit

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
