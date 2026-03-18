//
//  SavedWorkoutCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class SavedWorkoutCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var savedWorkoutModel: SavedWorkoutModel
    var listener: SavedWorkoutRemoveListener?
    var subscriptionManager: PurchaseManager
    
    init(navigationController: UINavigationController, savedWorkoutModel: SavedWorkoutModel, listener: SavedWorkoutRemoveListener? = nil, subscriptionManager: PurchaseManager) {
        self.navigationController = navigationController
        self.savedWorkoutModel = savedWorkoutModel
        self.listener = listener
        self.subscriptionManager = subscriptionManager
    }
    
    func start() {
        let vc = SavedWorkoutDisplayViewController()
        vc.coordinator = self
        vc.viewModel.savedWorkout = savedWorkoutModel
        vc.bottomViewChildVC.viewModel.listListener = listener
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Methods
extension SavedWorkoutCoordinator {
    func showWorkoutStats() {
        let vc = DisplayWorkoutStatsViewController()
        vc.viewModel.savedWorkoutModel = savedWorkoutModel
        navigationController.pushViewController(vc, animated: true)
    }
    func showUser(_ user: Users) {
        let child = UserProfileCoordinator(navigationController: navigationController, user: user, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
    func showDescriptions(_ exercise: DiscoverExerciseModel) {
        let child = ExerciseDiscoveryCoordinator(navigationController: navigationController, exercise: exercise, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
    func showWorkoutDiscovery() {
        let child = WorkoutDiscoveryCoordinator(navigationController: navigationController, savedWorkoutModel: savedWorkoutModel, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
    func showAssign(_ model: SavedWorkoutModel) {
        let vc = AssigningSelectionViewController()
        vc.viewModel.savedWorkoutModel = model
        navigationController.pushViewController(vc, animated: true)
    }
    func showSingleSet(fromViewControllerDelegate: AnimatingSingleSet, setModel: ExerciseSet) {
        let child = SingleSetCoordinator(navigationController: navigationController, fromViewControllerDelegate: fromViewControllerDelegate, setModel: setModel)
        childCoordinators.append(child)
        child.start()
    }

}
protocol SavedWorkoutsFlow: AnyObject {
    func savedWorkoutSelected(_ selectedWorkout: SavedWorkoutModel, listener: SavedWorkoutRemoveListener?)
}
