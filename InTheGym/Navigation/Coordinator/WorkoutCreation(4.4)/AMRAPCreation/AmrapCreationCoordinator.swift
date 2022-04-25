//
//  AmrapCreationCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//


import Foundation
import UIKit

class AmrapCreationCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var workoutViewModel: WorkoutCreationViewModel
    var workoutPosition: Int
    
    init(navigationController: UINavigationController, workoutViewModel: WorkoutCreationViewModel, workoutPosition: Int) {
        self.navigationController = navigationController
        self.workoutViewModel = workoutViewModel
        self.workoutPosition = workoutPosition
    }
    
    func start() {
        let vc = CreateAMRAPViewController()
        vc.newCoordinator = self
        vc.viewModel.workoutViewModel = workoutViewModel
        navigationController.pushViewController(vc, animated: true)
    }
}

extension AmrapCreationCoordinator {
    func upload() {
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: WorkoutCreationViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
    func exercise(viewModel: CreateAMRAPViewModel, exercisePosition: Int) {
        viewModel.workoutPosition = workoutPosition
        let child = AmrapExerciseSelectionCoordinator(navigationController: navigationController, amrapViewModel: viewModel, workoutPosition: exercisePosition)
        childCoordinators.append(child)
        child.start()
    }
}

//MARK: - Navigation Delegate Method
extension AmrapCreationCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
        
    }
}


