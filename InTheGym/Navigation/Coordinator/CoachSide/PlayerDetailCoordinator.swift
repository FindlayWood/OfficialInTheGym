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
        let child = RegularWorkoutCreationCoordinator(navigationController: navigationController, assignTo: player)
        childCoordinators.append(child)
        child.start()
    }
    func showPerformance(_ user: Users) {
        let vc = PerformanceMonitorViewController()
        vc.viewModel.user = user
        navigationController.pushViewController(vc, animated: true)
    }
    func showWorkout(_ model: WorkoutModel) {
        let vc = CoachPlayerWorkoutViewController()
        vc.viewModel.workoutModel = model
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    func viewClip(_ clipModel: WorkoutClipModel, fromViewControllerDelegate: CustomAnimatingClipFromVC) {
        let keyClipModel = KeyClipModel(clipKey: clipModel.clipKey, storageURL: clipModel.storageURL)
        let child = ClipProfileCustomCoordinator(navigationController: navigationController, clipModel: keyClipModel, fromViewControllerDelegate: fromViewControllerDelegate)
        childCoordinators.append(child)
        child.start()
    }
    func showDescriptions(_ exercise: DiscoverExerciseModel) {
        let child = ExerciseDiscoveryCoordinator(navigationController: navigationController, exercise: exercise)
        childCoordinators.append(child)
        child.start()
    }
    func showSingleSet(fromViewControllerDelegate: AnimatingSingleSet, setModel: ExerciseSet) {
        let child = SingleSetCoordinator(navigationController: navigationController, fromViewControllerDelegate: fromViewControllerDelegate, setModel: setModel)
        childCoordinators.append(child)
        child.start()
    }
}
