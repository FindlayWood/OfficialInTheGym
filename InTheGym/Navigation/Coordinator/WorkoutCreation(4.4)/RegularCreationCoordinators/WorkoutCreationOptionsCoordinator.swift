//
//  WorkoutCreationOptionsCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class WorkoutCreationOptionsCoordinator: Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    var navigationModel: WorkoutCreationOptionsNavigationModel
    var modalNavigationController: UINavigationController!
    // MARK: - Initializer
    init(navigationController: UINavigationController, navigationModel: WorkoutCreationOptionsNavigationModel) {
        self.navigationController = navigationController
        self.navigationModel = navigationModel
    }
    // MARK: - Start
    func start() {
        let vc = WorkoutCreationOptionsViewController()
        vc.viewModel.saving = navigationModel.isSaving
        vc.viewModel.isPrivate = navigationModel.isPrivate
        vc.viewModel.assignTo = navigationModel.assignTo
        vc.viewModel.currentTags = navigationModel.currentTags
        vc.viewModel.toggledSaving = navigationModel.toggledSaving
        vc.viewModel.toggledPrivacy = navigationModel.toggledPrivacy
        vc.viewModel.addNewTagPublisher = navigationModel.addedNewTag
        vc.coordinator = self
        modalNavigationController = UINavigationController(rootViewController: vc)
        navigationController.present(modalNavigationController, animated: true)
    }
}
// MARK: - Flow
extension WorkoutCreationOptionsCoordinator {
    func addNewTag(_ model: AddWorkoutTagsNavigationModel) {
        let vc = AddWorkoutTagsViewController()
        vc.viewModel.currentTags = model.currentTags
        vc.viewModel.addNewTagPublisher = model.addedNewTagPublisher
        modalNavigationController.present(vc, animated: true)
    }
    func dismiss() {
        navigationController.dismiss(animated: true)
    }
}
