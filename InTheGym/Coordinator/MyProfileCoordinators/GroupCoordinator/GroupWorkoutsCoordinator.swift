//
//  GroupWorkoutsCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

protocol SavedWorkoutsFlow: AnyObject {
    func savedWorkoutSelected(_ selectedWorkout: SavedWorkoutModel)
}

class GroupWorkoutsCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var group: groupModel
    
    init(navigationController: UINavigationController, group: groupModel) {
        self.navigationController = navigationController
        self.group = group
    }
    
    func start() {
        let vc = GroupWorkoutsViewController()
        vc.currentGroup = group
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
    func showWorkout(_ workout: WorkoutDelegate) {
        let child = WorkoutCoordinator(navigationController: navigationController, workout: workout)
        childCoordinators.append(child)
        child.start()
    }
}


