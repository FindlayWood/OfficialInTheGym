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
    var modalNavigationController: UINavigationController!
    var replayModelNavigationController: UINavigationController!
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    // MARK: - Start
    func start() {
//        let vc = JumpMeasuringViewController()
//        vc.coordinator = self
//        modalNavigationController = UINavigationController(rootViewController: vc)
//        modalNavigationController.modalPresentationStyle = .fullScreen
//        navigationController.present(modalNavigationController, animated: true)
    }
}
// MARK: - Flow
extension RecordJumpCoordinator {
    func showJump(_ outputURL: URL) {
//        let vc = ReplayJumpMeasureViewController()
//        vc.viewModel.fileURL = outputURL
//        vc.coordinator = self
//        replayModelNavigationController = UINavigationController(rootViewController: vc)
//        replayModelNavigationController.modalPresentationStyle = .fullScreen
//        modalNavigationController.present(replayModelNavigationController, animated: false)
//        let modalNavigationController = UINavigationController(rootViewController: vc)
//        modalNavigationController.modalPresentationStyle = .fullScreen
//        navigationController.present(modalNavigationController, animated: true)
    }
}
// MARK: - Results Flow
extension RecordJumpCoordinator: JumpResultsFlow {
    func showResult(_ height: Double) {
//        let vc = JumpResultsViewController()
//        vc.viewModel.currentValue = height
//        vc.viewModel.jumpResultCM = height
//        replayModelNavigationController.present(vc, animated: true)
    }
}
