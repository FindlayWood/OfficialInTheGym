//
//  SavedWorkoutCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class SavedWorkoutCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var savedWorkoutModel: SavedWorkoutModel
    
    init(navigationController: UINavigationController, savedWorkoutModel: SavedWorkoutModel) {
        self.navigationController = navigationController
        self.savedWorkoutModel = savedWorkoutModel
    }
    
    func start() {
        let vc = SavedWorkoutDisplayViewController()
        vc.coordinator = self
        vc.viewModel.savedWorkout = savedWorkoutModel
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Methods
extension SavedWorkoutCoordinator {
    
    func showOptions(for workout: SavedWorkoutModel) {
        let vc = SavedWorkoutOptionsViewController()
        vc.viewModel.savedWorkout = workout
        vc.coordinator = self
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func showWorkoutStats(with savedWorkoutID: String) {
        navigationController.dismiss(animated: true)
        let vc = DisplayWorkoutStatsViewController()
        vc.savedWorkoutID = savedWorkoutID
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showUser(_ user: Users) {
        navigationController.dismiss(animated: true)
        let child = UserProfileCoordinator(navigationController: navigationController, user: user)
        childCoordinators.append(child)
        child.start()
    }
    
    func showDescriptions(_ exercise: ExerciseModel) {
        let vc = ExerciseDescriptionViewController()
        vc.viewModel.exercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showEMOM(_ emom: EMOMModel) {
        let vc = DisplayEMOMViewController()
        vc.viewModel.emomModel = emom
        navigationController.pushViewController(vc, animated: true)
    }
    func showCircuit(_ circuit: CircuitModel) {
        let vc = DisplayCircuitViewController()
        vc.viewModel.circuitModel = circuit
        navigationController.pushViewController(vc, animated: true)
    }
    func showAMRAP(_ amrap: AMRAPModel) {
        let vc = DisplayAMRAPViewController()
        vc.viewModel.amrapModel = amrap
        navigationController.pushViewController(vc, animated: true)
    }

}

// MARK: - Custom Clip Picker
extension SavedWorkoutCoordinator: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = BottomViewPresentationController(presentedViewController: presented, presenting: presenting)
        controller.viewHeightPrecentage = 0.7
        return controller
    }
}
