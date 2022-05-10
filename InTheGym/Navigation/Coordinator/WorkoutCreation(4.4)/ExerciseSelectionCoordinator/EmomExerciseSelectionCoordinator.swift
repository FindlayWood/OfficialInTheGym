//
//  EmomExerciseSelectionCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class EmomExerciseSelectionCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var emomViewModel: CreateEMOMViewModel
    var workoutPosition: Int
    
    init(navigationController: UINavigationController, emomViewModel: CreateEMOMViewModel, workoutPosition: Int) {
        self.navigationController = navigationController
        self.emomViewModel = emomViewModel
        self.workoutPosition = workoutPosition
    }
    
    func start() {
        let vc = ExerciseSelectionViewController()
//        vc.newCoordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Exercise Selection Flow
//extension EmomExerciseSelectionCoordinator: RegularExerciseSelectionFlow {
//    
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
//    func exercise(viewModel: ExerciseCreationViewModel) {
//        viewModel.exercisekind = .emom
//        viewModel.addingDelegate = emomViewModel
//        viewModel.exercise.workoutPosition = workoutPosition
//        let child = RepsSelectionCoordinator(navigationController: navigationController, exerciseViewModel: viewModel)
//        childCoordinators.append(child)
//        child.start()
//    }
//    
//    
//}
