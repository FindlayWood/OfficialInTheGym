//
//  RegularWeightSelectionCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class RegularWeightSelectionCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var exerciseViewModel: ExerciseCreationViewModel
    
    init(navigationController: UINavigationController, exerciseViewModel: ExerciseCreationViewModel) {
        self.navigationController = navigationController
        self.exerciseViewModel = exerciseViewModel
    }
    
    func start() {
        let vc = NewWeightViewController()
        vc.exerciseViewModel = exerciseViewModel
        vc.newCoordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Weight Selection Flow
extension RegularWeightSelectionCoordinator: WeightSelectionFlow {
    func next() {
        let child = AddMoreToExerciseCoordinator(navigationController: navigationController, creationViewModel: exerciseViewModel)
        childCoordinators.append(child)
        child.start()
        
//        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
//        switch exerciseViewModel.exercisekind {
//        case .regular:
//            for controller in viewControllers {
//                if controller.isKind(of: WorkoutCreationViewController.self) {
//                    navigationController.popToViewController(controller, animated: true)
//                    break
//                }
//            }
//        case .circuit:
//            for controller in viewControllers {
//                if controller.isKind(of: CreateCircuitViewController.self) {
//                    navigationController.popToViewController(controller, animated: true)
//                    break
//                }
//            }
//        case .emom:
//            for controller in viewControllers {
//                if controller.isKind(of: CreateEMOMViewController.self) {
//                    navigationController.popToViewController(controller, animated: true)
//                    break
//                }
//            }
//        case .amrap:
//            for controller in viewControllers {
//                if controller.isKind(of: CreateAMRAPViewController.self) {
//                    navigationController.popToViewController(controller, animated: true)
//                    break
//                }
//            }
//        case .live:
//            for controller in viewControllers {
//                if controller.isKind(of: LiveWorkoutDisplayViewController.self) {
//                    navigationController.popToViewController(controller, animated: true)
//                    break
//                }
//            }
//        }
    }
}
