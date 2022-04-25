//
//  GroupWorkoutsCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

protocol SavedWorkoutsFlow: AnyObject {
    func savedWorkoutSelected(_ selectedWorkout: SavedWorkoutModel, listener: SavedWorkoutRemoveListener?)
}

class GroupWorkoutsCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var group: GroupModel
    
    init(navigationController: UINavigationController, group: GroupModel) {
        self.navigationController = navigationController
        self.group = group
    }
    
    func start() {
        let vc = GroupWorkoutsViewController()
        vc.viewModel.group = group
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Group Workout Flow
extension GroupWorkoutsCoordinator {
    func addNewWorkout() {
        let child = AddGroupWorkoutCoordinator(navigationController: navigationController, group: group)
        childCoordinators.append(child)
        child.start()
    }
    func showSavedWorkout(_ workout: SavedWorkoutModel) {
        let child = SavedWorkoutCoordinator(navigationController: navigationController, savedWorkoutModel: workout)
        childCoordinators.append(child)
        child.start()
    }
}


