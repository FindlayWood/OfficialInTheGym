//
//  CompletedWorkoutCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class CompletedWorkoutCoordinator: Coordinator {
    /// this coordinators child coordinators
    var childCoordinators = [Coordinator]()
    /// navigation controller for this coordinator
    var navigationController: UINavigationController
    /// modal navigation controller to display over this screen
    var modalNavigationController: UINavigationController?
    /// workout model needed to start this coordinator
    var workoutModel: WorkoutModel
    
    init(navigationController: UINavigationController, workoutModel: WorkoutModel) {
        self.navigationController = navigationController
        self.workoutModel = workoutModel
    }
    
    /// method to start this coordinator
    func start() {
        let vc = CompletedWorkoutPageViewController()
        vc.viewModel.workout = workoutModel
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
extension CompletedWorkoutCoordinator {
    /// method to show the completed workout screen
    /// needs to use the modal navigation controller to present onto a presented VC
    /// takes a workout model
    func completedUpload(_ model: WorkoutModel) {
        modalNavigationController = UINavigationController()
        let vc = PostCompletedWorkoutViewController()
        modalNavigationController?.setViewControllers([vc], animated: true)
        vc.viewModel.workoutModel = model
        vc.coordinator = self
        if let modalNavigationController = modalNavigationController {
            navigationController.present(modalNavigationController, animated: true)
        }
    }
    func postWorkout(_ model: WorkoutModel) {
        guard let modalNavigationController = modalNavigationController else {return}
        let child = CreateNewPostCoordinator(navigationController: modalNavigationController, postable: PostModel(), listener: nil, workout: model)
        childCoordinators.append(child)
        child.start()
    }
    func dismiss() {
        navigationController.dismiss(animated: true)
    }
}

