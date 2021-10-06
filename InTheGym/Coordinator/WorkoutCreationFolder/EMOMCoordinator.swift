//
//  EMOMCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class EMOMCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = CreateEMOMViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

extension EMOMCoordinator: EMOMFlow {
    func addExercise(_ exercise: exercise) {
        if #available(iOS 13, *) {
            let vc = ExerciseSelectionViewController()
            vc.coordinator = self
            vc.newExercise = exercise
            navigationController.pushViewController(vc, animated: true)
        } else {
            let vc = BodyTypeViewController.instantiate()
            vc.coordinator = self
            vc.newExercise = exercise
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func bodyTypeSelected(_ exercise: exercise) {
        let vc = ExerciseViewController.instantiate()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func otherSelected(_ exercise: exercise) {
        let vc = OtherExerciseViewController()
        vc.newExercise = exercise
        vc.coordinator = self
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func exerciseSelected(_ exercise: exercise) {
        let vc = NewRepsViewController.instantiate()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func repsSelected(_ exercise: exercise) {
        let vc = NewWeightViewController.instantiate()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func weightSelected(_ exercise: exercise) {
        CreateEMOMViewController.exercises.append(exercise)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: CreateEMOMViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
//        CreateAMRAPViewController.exercises.append(exercise)
//        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
//        for controller in viewControllers {
//            if controller.isKind(of: CreateAMRAPViewController.self) {
//                navigationController.popToViewController(controller, animated: true)
//                break
//            }
//        }
    }
    func upload() {
        
    }
}

extension EMOMCoordinator {
    func showTimePicker(with delegate: TimeSelectionParentDelegate, time: Int) {
        let child = TimeSelectionPickerCoordinator(navigationController: navigationController, parent: delegate, currentTime: time)
        childCoordinators.append(child)
        child.start()
    }
}
