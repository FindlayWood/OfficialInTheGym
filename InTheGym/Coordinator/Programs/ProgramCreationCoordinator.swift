//
//  ProgramCreationCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ProgramCreationCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var savedWorkoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = ProgramCreationViewController()
        vc.coordinator = self
        vc.viewModel.isCreating = true
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

extension ProgramCreationCoordinator {
    func addSavedWorkout() {
        let vc = SavedWorkoutsViewController()
        vc.coordinator = self
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func showDetailPage(with model: CreateProgramModel) {
        let vc = ProgramCreationDetailViewController()
        vc.viewModel.createdProgram = model
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

extension ProgramCreationCoordinator: SavedWorkoutsFlow {
    func savedWorkoutSelected(_ selectedWorkout: SavedWorkoutModel) {
        savedWorkoutSelected.send(selectedWorkout)
        navigationController.dismiss(animated: true)
    }
}

// MARK: - Custom Clip Picker
extension ProgramCreationCoordinator: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = BottomViewPresentationController(presentedViewController: presented, presenting: presenting)
        controller.viewHeightPrecentage = 0.8
        return controller
    }
}
