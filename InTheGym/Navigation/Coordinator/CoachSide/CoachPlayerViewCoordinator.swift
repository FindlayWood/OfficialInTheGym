//
//  CoachPlayerViewCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CoachPlayerViewCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var player: Users
    init(navigationController: UINavigationController, player: Users) {
        self.navigationController = navigationController
        self.player = player
    }
    
    func start() {
        let vc = PlayerViewController.instantiate()
        vc.player = player
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

extension CoachPlayerViewCoordinator {
    func addWorkout() {
        let child = RegularWorkoutCoordinator(navigationController: navigationController, assignTo: player)
        childCoordinators.append(child)
        child.start()
    }
    func viewWorkouts() {
        let vc = ViewWorkoutViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
