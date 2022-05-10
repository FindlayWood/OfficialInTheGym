//
//  LiveExerciseSelectionCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class LiveExerciseSelectionCoordinator: NSObject, Coordinator {
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
//        vc.newCoordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Exercise Selection Flow
//extension LiveExerciseSelectionCoordinator: RegularExerciseSelectionFlow {
//    func circuit() {
//        
//    }
//    
//    func emom() {
//    
//    }
//    
//    func amrap() {
//        
//    }
//    
//    
//    func exercise(viewModel: ExerciseCreationViewModel) {        
//        //viewModel.exercisekind = .live
//        viewModel.exercise.workoutPosition = workoutPosition
//        viewModel.addingDelegate = workoutCreationViewModel
//        viewModel.addingDelegate.addExercise(viewModel.exercise)
//        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
//        for controller in viewControllers {
//            if controller.isKind(of: LiveWorkoutDisplayViewController.self) {
//                navigationController.popToViewController(controller, animated: true)
//                break
//            }
//        }
//    }
//}
