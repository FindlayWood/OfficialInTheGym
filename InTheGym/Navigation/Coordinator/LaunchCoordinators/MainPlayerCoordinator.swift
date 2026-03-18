//
//  MainPlayerCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class MainPlayerCoordinator: Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    var subscriptionManager: PurchaseManager
    // MARK: - Initializer
    init(navigationController: UINavigationController, subscriptionManager: PurchaseManager) {
        self.navigationController = navigationController
        self.subscriptionManager = subscriptionManager
    }
    // MARK: - Start
    func start() {
        let vc = PlayerInitialViewController(subscriptionManager: subscriptionManager)
        vc.navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([vc], animated: true)
    }
}
