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
    
    init(navigationController: UINavigationController, amrapViewModel: CreateAMRAPViewModel) {
        self.navigationController = navigationController
        self.amrapViewModel = amrapViewModel
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
        let child = RepsSelectionCoordinator(navigationController: navigationController, exerciseViewModel: viewModel)
        childCoordinators.append(child)
        child.start()
    }
    
    
}
