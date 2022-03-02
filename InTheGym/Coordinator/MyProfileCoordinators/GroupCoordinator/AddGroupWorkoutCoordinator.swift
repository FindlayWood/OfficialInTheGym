//
//  AddGroupWorkoutCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddGroupWorkoutCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var group: GroupModel
    init(navigationController: UINavigationController, group: GroupModel) {
        self.navigationController = navigationController
        self.group = group
    }
    func start() {
        let vc = AddGroupWorkoutTypeViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Flow
extension AddGroupWorkoutCoordinator {
    func addNewWorkout() {
        let child = RegularWorkoutCoordinator(navigationController: navigationController, assignTo: group)
        childCoordinators.append(child)
        child.start()
    }
    func addSavedWorkout() {
        let vc = SavedWorkoutsViewController.instantiate()
        vc.coordinator = self
        navigationController.present(vc, animated: true, completion: nil)
    }
    func continueWith(savedWorkout: savedWorkoutDelegate) {
        let vc = UploadGroupWorkoutViewController()
        vc.workoutToUpload = UploadableWorkout(assignee: group, workout: savedWorkout)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    func selectPlayers(selectedPlayers: [Users], delegate: SelectPlayersProtocol) {
        let vc = GroupAddPlayersViewController()
        vc.alreadySelectedPlayers = selectedPlayers
        vc.delegate = delegate
        navigationController.present(vc, animated: true, completion: nil)
    }
    func goToWorkout(_ selectedWorkout: WorkoutDelegate) {
        let child = WorkoutCoordinator(navigationController: navigationController, workout: selectedWorkout)
        childCoordinators.append(child)
        child.start()
    }
}

// MARK: - Saved Workout Flow
extension AddGroupWorkoutCoordinator: SavedWorkoutsFlow {
    func savedWorkoutSelected(_ selectedWorkout: SavedWorkoutModel) {
//        navigationController.dismiss(animated: true, completion: nil)
//        continueWith(savedWorkout: selectedWorkout)
    }
}
