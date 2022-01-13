//
//  Amrap&EmomExerciseSelectionCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class AmrapExerciseSelectionCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var amrapViewModel: CreateAMRAPViewModel
    var workoutPosition: Int
    
    init(navigationController: UINavigationController, amrapViewModel: CreateAMRAPViewModel, workoutPosition: Int) {
        self.navigationController = navigationController
        self.amrapViewModel = amrapViewModel
        self.workoutPosition = workoutPosition
    }
    
    func start() {
        let vc = ExerciseSelectionViewController()
        vc.newCoordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Exercise Selection Flow
extension AmrapExerciseSelectionCoordinator: ExerciseSelectionFlow {
    func ciruit() {
            
    }
    
    func emom() {
        
    }
    
    func amrap() {
        
    }
    
    func exercise(viewModel: ExerciseCreationViewModel) {
        viewModel.exercisekind = .amrap
        viewModel.addingDelegate = amrapViewModel
        viewModel.exercise.workoutPosition = workoutPosition
        let child = RepsSelectionCoordinator(navigationController: navigationController, exerciseViewModel: viewModel)
        childCoordinators.append(child)
        child.start()
    }
    
    
}
