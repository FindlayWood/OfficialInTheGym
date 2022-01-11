//
//  RegularExerciseSelectionCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class RegularExerciseSelectionCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var workoutCreationViewModel: ExerciseAdding
    var workoutPosition: Int
    
    init(navigationController: UINavigationController, creationViewModel: ExerciseAdding, workoutPosition: Int) {
        self.navigationController = navigationController
        self.workoutCreationViewModel = creationViewModel
        self.workoutPosition = workoutPosition
    }
    
    func start() {
        let vc = ExerciseSelectionViewController()
        vc.workoutCreationViewModel = workoutCreationViewModel
        vc.newCoordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Exercise Selection Flow
extension RegularExerciseSelectionCoordinator: ExerciseSelectionFlow {
    func ciruit() {
        let child = CircuitCreationCoordinator(navigationController: navigationController, workoutViewModel: workoutCreationViewModel as! WorkoutCreationViewModel)
        childCoordinators.append(child)
        child.start()
    }
    
    func emom() {
        let child = EmomCreationCoordinator(navigationController: navigationController, workoutViewModel: workoutCreationViewModel as! WorkoutCreationViewModel)
        childCoordinators.append(child)
        child.start()
    }
    
    func amrap() {
        let child = AmrapCreationCoordinator(navigationController: navigationController, workoutViewModel: workoutCreationViewModel as! WorkoutCreationViewModel)
        childCoordinators.append(child)
        child.start()
    }
    
    func exercise(viewModel: ExerciseCreationViewModel) {
        viewModel.workoutPosition = workoutPosition
        viewModel.exercise.workoutPosition = workoutPosition
        viewModel.addingDelegate = workoutCreationViewModel
        let child = SetsSelectionCoordinator(navigationController: navigationController, exerciseViewModel: viewModel)
        childCoordinators.append(child)
        child.start()
    }
}

//MARK: - Navigation Delegate Method
extension RegularExerciseSelectionCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
        
        if let CircuitViewController = fromViewController as? CreateCircuitViewController {
            childDidFinish(CircuitViewController.newCoordinator)
        }
        
        if let AmrapViewController = fromViewController as? CreateAMRAPViewController {
            childDidFinish(AmrapViewController.newCoordinator)
        }
        
        if let SetsViewController = fromViewController as? ExerciseSetsViewController {
            childDidFinish(SetsViewController.newCoordinator)
        }
    }
}
