//
//  WorkoutCreationCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class WorkoutCreationCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var assignTo: Users?
    
    init(navigationController: UINavigationController, assignTo: Users?) {
        self.navigationController = navigationController
        self.assignTo = assignTo
    }            
    func start() {
        let vc = WorkoutCreationViewController()
        vc.coordinator = self
        vc.viewModel.assignTo = assignTo
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

extension WorkoutCreationCoordinator {
    func upload() {
        
    }
    func plus(viewModel: ExerciseAdding, workoutPosition: Int) {
        let child = RegularExerciseSelectionCoordinator(navigationController: navigationController, creationViewModel: viewModel, workoutPosition: workoutPosition)
        childCoordinators.append(child)
        child.start()
    }
}
