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
    weak var parentCoordinator: CreationFlow?
    
    init(navigationController: UINavigationController, creationViewModel: ExerciseCreationViewModel) {
        self.navigationController = navigationController
        self.creationViewModel = creationViewModel
    }
    func start() {
        let vc = AddMoreToExerciseViewController()
        vc.viewModel.exerciseCreationViewModel = creationViewModel
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

extension AddMoreToExerciseCoordinator {
    func timeSelected(_ cellModel: AddMoreCellModel) {
        let vc = AddMoreTimeViewController()
        vc.coordinator = self
        vc.cellModel = cellModel
        vc.exerciseViewModel = creationViewModel
        navigationController.pushViewController(vc, animated: true)
    }
    func distanceSelected(_ cellModel: AddMoreCellModel) {
        let vc = AddMoreDistanceViewController()
        vc.coordinator = self
        vc.cellModel = cellModel
        vc.exerciseViewModel = creationViewModel
        navigationController.pushViewController(vc, animated: true)
    }
    func restTimeSelected(_ cellModel: AddMoreCellModel) {
        let vc = AddMoreRestTimeViewController()
        vc.coordinator = self
        vc.cellModel = cellModel
        vc.exerciseViewModel = creationViewModel
        navigationController.pushViewController(vc, animated: true)
    }
    func noteSelected(_ cellModel: AddMoreCellModel) {
        let vc = AddMoreNoteViewController()
//        if newExercise.note != nil {
//            vc.currentNote = newExercise.note
//        }
        vc.cellModel = cellModel
        vc.coordinator = self
        vc.exerciseViewModel = creationViewModel
        navigationController.present(vc, animated: true)
    }
    func timeAdded(_ timeInSeconds: Int) {
        navigationController.popViewController(animated: true)
//        if parentCoordinator is RegularWorkoutCoordinator {
//            guard let sets = newExercise.sets else {return}
//            let timeArray = Array(repeating: timeInSeconds, count: sets)
//            newExercise.time = timeArray
//            navigationController.popViewController(animated: true)
//        } else if parentCoordinator is LiveWorkoutCoordinator {
//            newExercise.time?.append(timeInSeconds)
//            navigationController.popViewController(animated: true)
//        }

    }
    func distanceAdded(_ distance: String) {
        navigationController.popViewController(animated: true)
//        if parentCoordinator is RegularWorkoutCoordinator {
//            guard let sets = newExercise.sets else {return}
//            let distacneArray = Array(repeating: distance, count: sets)
//            newExercise.distance = distacneArray
//            navigationController.popViewController(animated: true)
//        } else if parentCoordinator is LiveWorkoutCoordinator {
//            newExercise.distance?.append(distance)
//            navigationController.popViewController(animated: true)
//        }
    }
    func restTimeAdded(_ restTimeInSeconds: Int) {
        navigationController.popViewController(animated: true)
//        if parentCoordinator is RegularWorkoutCoordinator {
//            guard let sets = newExercise.sets else {return}
//            let restTimeArray = Array(repeating: restTimeInSeconds, count: sets)
//            newExercise.restTime = restTimeArray
//            navigationController.popViewController(animated: true)
//        } else if parentCoordinator is LiveWorkoutCoordinator {
//            newExercise.restTime?.append(restTimeInSeconds)
//            navigationController.popViewController(animated: true)
//        }
    }
    func noteAdded(_ noteText: String) {
//        navigationController.popViewController(animated: true)
//        newExercise.note = noteText
    }
    func addNewExercise() {
        creationViewModel.addingDelegate.addExercise(creationViewModel.exercise)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        switch creationViewModel.exercisekind {
        case .regular:
            for controller in viewControllers {
                if controller.isKind(of: WorkoutCreationViewController.self) {
                    navigationController.popToViewController(controller, animated: true)
                    break
                }
            }
        case .circuit:
            for controller in viewControllers {
                if controller.isKind(of: CreateCircuitViewController.self) {
                    navigationController.popToViewController(controller, animated: true)
                    break
                }
            }
        case .emom:
            for controller in viewControllers {
                if controller.isKind(of: CreateEMOMViewController.self) {
                    navigationController.popToViewController(controller, animated: true)
                    break
                }
            }
        case .amrap:
            for controller in viewControllers {
                if controller.isKind(of: CreateAMRAPViewController.self) {
                    navigationController.popToViewController(controller, animated: true)
                    break
                }
            }
        case .live:
            for controller in viewControllers {
                if controller.isKind(of: LiveWorkoutDisplayViewController.self) {
                    navigationController.popToViewController(controller, animated: true)
                    break
                }
            }
        }
//        let object = newExercise.toObject()
//        AddWorkoutHomeViewController.exercises.append(object)
//        //DisplayWorkoutViewController.selectedWorkout.exercises?.append(newExercise)
//        parentCoordinator?.completeExercise()
    }
    
}
