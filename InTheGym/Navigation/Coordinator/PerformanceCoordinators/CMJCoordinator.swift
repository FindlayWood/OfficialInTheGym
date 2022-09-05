//
//  CMJCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/07/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

/// responsible for the navigation flow for CMJ jumps
/// home page -> recording jumo -> jump replay -> results
class CMJCoordinator: NSObject, Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    var modalNavigationController: UINavigationController!
    var replayModelNavigationController: UINavigationController!
    
    var jumpModel: CMJModel?
    var measurementsModel: MeasurementModel!
    
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Start
    func start() {
        let vc = CMJHomeViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Methods
extension CMJCoordinator: JumpCoordinatorFlow {
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
        // TODO: - Show Specific Results Page
        let vc = CMJResultsViewController()
        vc.viewModel.height = height
        vc.viewModel.jumpModel = jumpModel
        vc.viewModel.measurementsModel = measurementsModel
        replayModelNavigationController.present(vc, animated: true)
    }
    
    /// to calculate power output - need user measurements
    func showMeasurements() {
        let vc = MyMeasurementsViewController()
        vc.modalPresentationStyle = .fullScreen
        navigationController.present(vc, animated: true)
    }
}
