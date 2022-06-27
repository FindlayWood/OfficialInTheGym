//
//  JumpCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class JumpCoordinator: Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    // MARK: - Start
    func start() {
        let vc = MyJumpsViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Flow
extension JumpCoordinator {
    func recordNewJump() {
        let child = RecordJumpCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
//        let vc = JumpMeasuringViewController()
//        vc.modalPresentationStyle = .fullScreen
//        navigationController.present(vc, animated: true)
    }
    func instructions() {
        let vc = JumpInstructionsViewController()
        navigationController.present(vc, animated: true)
    }
    func jumpHistory() {
        
    }
}
