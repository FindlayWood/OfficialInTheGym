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
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    // MARK: - Start
    func start() {
        let vc = PlayerInitialViewController()
        vc.navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(vc, animated: false)
    }
}
