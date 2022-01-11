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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = ExerciseSelectionViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Exercise Selection Flow
extension LiveExerciseSelectionCoordinator: ExerciseSelectionFlow {
    
    func ciruit() {
            
    }
    
    func emom() {
        
    }
    
    func amrap() {
        
    }
    
    func exercise(viewModel: ExerciseCreationViewModel) {
        
    }
    
    
}
