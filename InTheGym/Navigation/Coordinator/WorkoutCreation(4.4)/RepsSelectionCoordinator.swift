//
//  RepsSelectionCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class RepsSelectionCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var exerciseViewModel: ExerciseCreationViewModel
    
    init(navigationController: UINavigationController, exerciseViewModel: ExerciseCreationViewModel) {
        self.navigationController = navigationController
        self.exerciseViewModel = exerciseViewModel
    }
    
    func start() {
        let vc = RepSelectionViewController()
//        vc.newCoordinator = self
//        vc.exerciseViewModel = exerciseViewModel
        navigationController.pushViewController(vc, animated: true)
    }
}

extension RepsSelectionCoordinator {
    func next(viewModel: ExerciseCreationViewModel) {
        let child = RegularWeightSelectionCoordinator(navigationController: navigationController, exerciseViewModel: viewModel)
        childCoordinators.append(child)
        child.start()
    }
}
