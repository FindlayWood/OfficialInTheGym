//
//  CircuitCreationCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class CircuitCreationCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var workoutViewModel: WorkoutCreationViewModel
    
    init(navigationController: UINavigationController, workoutViewModel: WorkoutCreationViewModel) {
        self.navigationController = navigationController
        self.workoutViewModel = workoutViewModel
    }
    
    func start() {
        let vc = CreateCircuitViewController()
        vc.newCoordinator = self
        vc.viewModel.workoutViewModel = workoutViewModel
        navigationController.pushViewController(vc, animated: true)
    }
}

extension CircuitCreationCoordinator {
    func upload() {
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: WorkoutCreationViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
    func exercise(viewModel: CreateCircuitViewModel) {
        let child = CircuitExerciseSelectionCoordinator(navigationController: navigationController, circuitViewModel: viewModel)
        childCoordinators.append(child)
        child.start()
    }
}

//MARK: - Navigation Delegate Method
extension CircuitCreationCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
        
    }
}

