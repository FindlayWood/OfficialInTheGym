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
    var loginKitComposer: LoginComposer
    var accountCreationComposer: AccountCreationComposer
    var subscriptionManager: PurchaseManager
    var accountCreatedCallback: () -> Void
    var userLoggedIn: () -> Void
    var userSignedOut: () -> Void
    
    func showLogin() {
        let interface = loginKitComposer.makeLoginInterface()
        interface.launch()
    }
    
    func showLoggedInPlayer() {
        let mainPlayerCoordinator = MainPlayerCoordinator(navigationController: navigationController, subscriptionManager: subscriptionManager)
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
        accountCreationComposer.startAccountCreation(email: email, uid: uid)
    }
    func showAccountCreated(for user: Users) {
        let vc = AccountCreatedViewController()
        vc.viewModel = AccountCreatedViewModel(purchaseManager: subscriptionManager)
        vc.baseFlow = self
        vc.user = user
        navigationController.setViewControllers([vc], animated: true)
    }
}
