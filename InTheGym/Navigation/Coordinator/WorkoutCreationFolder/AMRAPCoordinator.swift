//
//  AMRAPCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class AMRAPCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    weak var parentDelegate: AmrapParentDelegate?
    
    init(navigationController: UINavigationController, parentDelegate: AmrapParentDelegate) {
        self.navigationController = navigationController
        self.parentDelegate = parentDelegate
    }
    
    func start() {
        let vc = CreateAMRAPViewController()
//        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Parent Creation Flow
extension AMRAPCoordinator {
    func completedAMRAP(amrapModel: AMRAP) {
        parentDelegate?.finishedCreatingAMRAP(amrapModel: amrapModel)
    }
}

// MARK: - Creation Flow
extension AMRAPCoordinator: CreationFlow {
    
    func addExercise(_ exercise: exercise) {
        let vc = ExerciseSelectionViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func otherSelected(_ exercise: exercise) {
        let vc = OtherExerciseViewController()
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func exerciseSelected(_ exercise: exercise) {
        let vc = RepSelectionViewController()
//        vc.coordinator = self
//        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    func repsSelected(_ exercise: exercise) {
//        let vc = NewWeightViewController.instantiate()
//        vc.coordinator = self
//        vc.newExercise = exercise
//        navigationController.pushViewController(vc, animated: true)
//        CreateAMRAPViewController.exercises.append(exercise)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: CreateAMRAPViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    func weightSelected(_ exercise: exercise) {
//        CreateAMRAPViewController.exercises.append(exercise)
//        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
//        for controller in viewControllers {
//            if controller.isKind(of: CreateAMRAPViewController.self) {
//                navigationController.popToViewController(controller, animated: true)
//                break
//            }
//        }
    }
    func completeExercise() {
        // not implemented
    }
}


