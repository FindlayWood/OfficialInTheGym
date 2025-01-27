//
//  AddPlayerCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class AddPlayerCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var modalNavigationController: UINavigationController!
    var currentPlayers: [Users]
    var subscriptionManager: PurchaseManager
    
    init(navigationController: UINavigationController, currentPlayers: [Users], subscriptionManager: PurchaseManager) {
        self.navigationController = navigationController
        self.currentPlayers = currentPlayers
        self.subscriptionManager = subscriptionManager
    }
    
    func start() {
        let vc = AddPlayerViewController()
        vc.viewModel.currentPlayers = currentPlayers
        vc.coordinator = self
        modalNavigationController = UINavigationController(rootViewController: vc)
        modalNavigationController.modalPresentationStyle = .fullScreen
        navigationController.present(modalNavigationController, animated: true)
    }
}
extension AddPlayerCoordinator {
    func showUser(_ user: Users) {
        let child = UserProfileCoordinator(navigationController: modalNavigationController, user: user, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
}
