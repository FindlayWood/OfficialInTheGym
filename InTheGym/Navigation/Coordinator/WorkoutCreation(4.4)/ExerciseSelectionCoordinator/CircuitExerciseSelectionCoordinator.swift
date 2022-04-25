//
//  CircuitExerciseSelectionCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class CircuitExerciseSelectionCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var circuitViewModel: CreateCircuitViewModel
    var workoutPosition: Int
    
    init(navigationController: UINavigationController, circuitViewModel: CreateCircuitViewModel, workoutPosition: Int) {
        self.navigationController = navigationController
        self.circuitViewModel = circuitViewModel
        self.workoutPosition = workoutPosition
    }
    
    func start() {
        let vc = ExerciseSelectionViewController()
        vc.newCoordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Exercise Selection Flow
extension CircuitExerciseSelectionCoordinator: RegularExerciseSelectionFlow {
    func circuit() {
        // NULL
    }
    
    func emom() {
        // NULL
    }
    
    func amrap() {
        // NULL
    }
    
    
    func exercise(viewModel: ExerciseCreationViewModel) {
        viewModel.exercisekind = .circuit
        viewModel.addingDelegate = circuitViewModel
        viewModel.exercise.workoutPosition = workoutPosition
        let child = SetsSelectionCoordinator(navigationController: navigationController, exerciseViewModel: viewModel)
        childCoordinators.append(child)
        child.start()
    }
    
    
}
