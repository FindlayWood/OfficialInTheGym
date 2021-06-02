//
//  LiveWorkoutCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class LiveWorkoutCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    var model: liveWorkout
    
    init(navigationController: UINavigationController, model: liveWorkout) {
        self.navigationController = navigationController
        self.model = model
    }
    
    func start() {
        let vc = DisplayWorkoutViewController.instantiate()
        DisplayWorkoutViewController.selectedWorkout = model
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

extension LiveWorkoutCoordinator: LiveDelegate {
    func showCompletedPage() {
        let vc = WorkoutCompletedViewController.instantiate()
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    func addExercise(_ exercise: exercise) {
        let vc = BodyTypeViewController.instantiate()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addSet(_ exercise: exercise) {
        let vc = NewRepsViewController.instantiate()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func weightSelected(_ exercise: exercise) {
        exercise.completedSets?.append(true)
        exercise.sets! += 1
        FirebaseLiveWorkoutUpdater.shared.update(DisplayWorkoutViewController.selectedWorkout)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: DisplayWorkoutViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    func bodyTypeSelected(_ exercise: exercise) {
        let vc = ExerciseViewController.instantiate()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func exerciseSelected(_ exercise: exercise) {
        // pop back to where live workout is displayed
        // TODO: - decide where live workout will be displayed
        exercise.completedSets = [Bool]()
        exercise.sets = 0
        exercise.repArray = [Int]()
        exercise.weightArray = [String]()
        DisplayWorkoutViewController.selectedWorkout.exercises?.append(exercise)
        FirebaseLiveWorkoutUpdater.shared.update(DisplayWorkoutViewController.selectedWorkout)
        
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: DisplayWorkoutViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    func repsSelected(_ exercise: exercise) {
        let vc = NewWeightViewController.instantiate()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    
    
    
    
}
