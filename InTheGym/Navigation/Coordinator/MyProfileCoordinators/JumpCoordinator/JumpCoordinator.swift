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
    var modalNavigationController: UINavigationController!
    var replayModelNavigationController: UINavigationController!
    var maxModel: VerticalJumpModel?
    var subscriptionManager: PurchaseManager
    // MARK: - Initializer
    init(navigationController: UINavigationController, subscriptionManager: PurchaseManager) {
        self.navigationController = navigationController
        self.subscriptionManager = subscriptionManager
    }
    // MARK: - Start
    func start() {
        if subscriptionManager.hasUnlockedPro {
            let vc = MyJumpsViewController()
            vc.coordinator = self
            navigationController.pushViewController(vc, animated: true)
        } else {
            let vc = PremiumAccountViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.viewModel = PremiumAccountViewModel(purchaseManager: subscriptionManager)
            navigationController.present(vc, animated: true)
        }

    }
}
// MARK: - Flow
extension JumpCoordinator: JumpCoordinatorFlow {
    func recordNewJump() {
        let vc = JumpMeasuringViewController()
        vc.coordinator = self
        modalNavigationController = UINavigationController(rootViewController: vc)
        modalNavigationController.modalPresentationStyle = .fullScreen
        navigationController.present(modalNavigationController, animated: true)
    }
    
    func showJump(_ outputURL: URL) {
        let vc = ReplayJumpMeasureViewController()
        vc.viewModel.fileURL = outputURL
        vc.coordinator = self
        replayModelNavigationController = UINavigationController(rootViewController: vc)
        replayModelNavigationController.modalPresentationStyle = .fullScreen
        modalNavigationController.present(replayModelNavigationController, animated: false)
    }
    
    func showResult(_ height: Double) {
        // TODO: - Show Specific Results page
        let vc = JumpResultsViewController()
        vc.viewModel.height = height
        vc.viewModel.maxModel = maxModel
        replayModelNavigationController.present(vc, animated: true)
    }
    func instructions() {
        let vc = JumpInstructionsViewController()
        navigationController.present(vc, animated: true)
    }
    func jumpHistory() {
        let vc = PreviousJumpsViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
