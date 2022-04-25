//
//  PlayerDetailCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class PlayerDetailCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var player: Users
    
    init(navigationController: UINavigationController, player: Users) {
        self.navigationController = navigationController
        self.player = player
    }
    
    func start() {
        let vc = PlayerDetailViewController()
        vc.viewModel.user = player
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

extension PlayerDetailCoordinator {
    func showPublicProfile() {
        let child = UserProfileCoordinator(navigationController: navigationController, user: player)
        childCoordinators.append(child)
        child.start()
    }
    func viewWorkouts() {
        let vc = CoachPlayerWorkoutsViewController()
        vc.viewModel.player = player
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    func addWorkout() {
        let child = WorkoutCreationCoordinator(navigationController: navigationController, assignTo: player)
        childCoordinators.append(child)
        child.start()
    }
    func showWorkout(_ model: WorkoutModel) {
        let vc = CoachPlayerWorkoutViewController()
        vc.viewModel.workoutModel = model
        navigationController.pushViewController(vc, animated: true)
    }
}
