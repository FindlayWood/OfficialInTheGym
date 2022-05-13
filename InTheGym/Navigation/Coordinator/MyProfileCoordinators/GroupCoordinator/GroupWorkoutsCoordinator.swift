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
    
    private var savedCompletionHandle: ((SavedWorkoutModel) -> Void)?
    
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
    func showSavedWorkout(_ workout: SavedWorkoutModel) {
        let child = SavedWorkoutCoordinator(navigationController: navigationController, savedWorkoutModel: workout)
        childCoordinators.append(child)
        child.start()
    }
}
extension GroupWorkoutsCoordinator: SavedWorkoutsFlow {
    func showSavedWorkoutPicker(completion: @escaping (SavedWorkoutModel) -> Void) {
        self.savedCompletionHandle = completion
        let vc = SavedWorkoutsViewController()
        vc.coordinator = self
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func savedWorkoutSelected(_ selectedWorkout: SavedWorkoutModel, listener: SavedWorkoutRemoveListener?) {
        savedCompletionHandle?(selectedWorkout)
        navigationController.dismiss(animated: true)
    }
}

