//
//  WorkoutDiscoveryCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class WorkoutDiscoveryCoordinator: Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    var savedWorkoutModel: SavedWorkoutModel
    // MARK: - Initializer
    init(navigationController: UINavigationController, savedWorkoutModel: SavedWorkoutModel) {
        self.navigationController = navigationController
        self.savedWorkoutModel = savedWorkoutModel
    }
    // MARK: - Start
    func start() {
        let vc = WorkoutDiscoveryViewController()
        vc.coordinator = self
        vc.commentsVC.coordinator = self
        vc.viewModel.savedWorkoutModel = savedWorkoutModel
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Flow
extension WorkoutDiscoveryCoordinator {
    func showSavedWorkout() {
        let child = SavedWorkoutCoordinator(navigationController: navigationController, savedWorkoutModel: savedWorkoutModel)
        childCoordinators.append(child)
        child.start()
    }
}
// MARK: - Description Flow
extension WorkoutDiscoveryCoordinator: DescriptionFlow {
    func addNewDescription(publisher: NewCommentListener) {
        let vc = DescriptionUploadViewController()
        vc.coordinator = self
        vc.viewModel.listener = publisher
        navigationController.present(vc, animated: true)
    }
    func uploadedNewDescription() {
        navigationController.dismiss(animated: true)
    }
    func dismiss() {
        navigationController.dismiss(animated: true)
    }
}
