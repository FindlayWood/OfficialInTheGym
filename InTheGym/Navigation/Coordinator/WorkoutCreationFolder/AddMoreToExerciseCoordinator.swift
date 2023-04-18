//
//  AddMoreToExerciseCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddMoreToExerciseCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var creationViewModel: ExerciseCreationViewModel
    
    init(navigationController: UINavigationController, creationViewModel: ExerciseCreationViewModel) {
        self.navigationController = navigationController
        self.creationViewModel = creationViewModel
    }
    func start() {
        let vc = AddMoreToExerciseViewController()
        vc.viewModel.exerciseCreationViewModel = creationViewModel
        navigationController.pushViewController(vc, animated: true)
    }
}

extension AddMoreToExerciseCoordinator {
    func timeSelected(_ cellModel: AddMoreCellModel) {
        let vc = AddMoreTimeViewController()
        vc.coordinator = self
        vc.cellModel = cellModel
        navigationController.pushViewController(vc, animated: true)
    }
    func distanceSelected(_ cellModel: AddMoreCellModel) {
        let vc = AddMoreDistanceViewController()
        vc.coordinator = self
        vc.cellModel = cellModel
        navigationController.pushViewController(vc, animated: true)
    }
    func restTimeSelected(_ cellModel: AddMoreCellModel) {
        let vc = AddMoreRestTimeViewController()
        vc.coordinator = self
        vc.cellModel = cellModel
        navigationController.pushViewController(vc, animated: true)
    }
    func noteSelected(_ cellModel: AddMoreCellModel) {
        let vc = AddMoreNoteViewController()
        vc.cellModel = cellModel
        vc.coordinator = self
        vc.exerciseViewModel = creationViewModel
        navigationController.present(vc, animated: true)
    }
    func timeAdded(_ timeInSeconds: Int) {
        navigationController.popViewController(animated: true)
    }
    func distanceAdded(_ distance: String) {
        navigationController.popViewController(animated: true)
    }
    func restTimeAdded(_ restTimeInSeconds: Int) {
        navigationController.popViewController(animated: true)
    }
    func noteAdded(_ noteText: String) {
    }
    func addNewExercise() {

        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        switch creationViewModel.exercisekind {
        case .regular:
            creationViewModel.addingDelegate.addExercise(creationViewModel.exercise)
            for controller in viewControllers {
                if controller.isKind(of: WorkoutCreationViewController.self) {
                    navigationController.popToViewController(controller, animated: true)
                    break
                }
            }
        case .circuit:
            creationViewModel.addingDelegate.addExercise(creationViewModel.exercise)
            for controller in viewControllers {
                if controller.isKind(of: CreateCircuitViewController.self) {
                    navigationController.popToViewController(controller, animated: true)
                    break
                }
            }
        case .emom:
            creationViewModel.addingDelegate.addExercise(creationViewModel.exercise)
            for controller in viewControllers {
                if controller.isKind(of: CreateEMOMViewController.self) {
                    navigationController.popToViewController(controller, animated: true)
                    break
                }
            }
        case .amrap:
            creationViewModel.addingDelegate.addExercise(creationViewModel.exercise)
            for controller in viewControllers {
                if controller.isKind(of: CreateAMRAPViewController.self) {
                    navigationController.popToViewController(controller, animated: true)
                    break
                }
            }
        case .live:
            creationViewModel.addingDelegate.updatedExercise(creationViewModel.exercise)
            for controller in viewControllers {
                if controller.isKind(of: LiveWorkoutDisplayViewController.self) {
                    navigationController.popToViewController(controller, animated: true)
                    break
                }
            }
        }
    }

}
