//
//  LiveWeightSelectionCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class LiveWeightSelectionCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var exerciseViewModel: ExerciseCreationViewModel
    
    init(navigationController: UINavigationController, exerciseViewModel: ExerciseCreationViewModel) {
        self.navigationController = navigationController
        self.exerciseViewModel = exerciseViewModel
    }
    
    func start() {
        let vc = NewWeightViewController()
        vc.exerciseViewModel = exerciseViewModel
        vc.newCoordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Weight Selection Flow
extension LiveWeightSelectionCoordinator: WeightSelectionFlow {
    func next() {
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: LiveWorkoutDisplayViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
}
