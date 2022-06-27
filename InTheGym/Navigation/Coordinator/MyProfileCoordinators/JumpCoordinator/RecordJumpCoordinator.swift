//
//  RecordJumpCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class RecordJumpCoordinator: Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    // MARK: - Start
    func start() {
        let vc = JumpMeasuringViewController()
        let modalNavigationController = UINavigationController(rootViewController: vc)
        modalNavigationController.modalPresentationStyle = .fullScreen
        navigationController.present(modalNavigationController, animated: true)
    }
}
// MARK: - Flow
extension RecordJumpCoordinator {
    func showJump() {
        
    }
    func showResults() {
        
    }
}
