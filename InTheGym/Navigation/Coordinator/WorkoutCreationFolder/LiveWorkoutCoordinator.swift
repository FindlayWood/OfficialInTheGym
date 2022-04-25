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

// MARK: - Creation Flow
extension LiveWorkoutCoordinator: CreationFlow {
    
    func addExercise(_ exercise: exercise) {
        if #available(iOS 13, *) {
            let vc = ExerciseSelectionViewController()
            vc.coordinator = self
            vc.newExercise = exercise
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func exerciseSelected(_ exercise: exercise) {
        // pop back to where live workout is displayed
        // TODO: - decide where live workout will be displayed
        exercise.completedSets = [Bool]()
        exercise.sets = 0
        exercise.repArray = [Int]()
        exercise.weightArray = [String]()
        //exercise.time = [Int]()
        //exercise.distance = [String]()
        //exercise.restTime = [Int]()
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
    
    func otherSelected(_ exercise: exercise) {
        let vc = OtherExerciseViewController()
        vc.newExercise = exercise
        vc.coordinator = self
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func repsSelected(_ exercise: exercise) {
        let vc = NewWeightViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func weightSelected(_ exercise: exercise) {
        exercise.completedSets?.append(true)
        exercise.sets! += 1
        FirebaseLiveWorkoutUpdater.shared.update(DisplayWorkoutViewController.selectedWorkout)
        let weight = exercise.weightArray?.last
        if let name = exercise.exercise,
           let reps = exercise.repArray?.last
        {
            FirebaseAPIWorkoutManager.shared.checkForExerciseStats(name: name, reps: reps, weight: weight)
        }
        
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: DisplayWorkoutViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    func completeExercise() {
        // not needed for live coordinator currently
        // future proofing
    }
}

// MARK: - Regular and Live Flow
extension LiveWorkoutCoordinator: RegularAndLiveFlow {
    func circuitSelected() {
        let child = CircuitCoordinator(navigationController: navigationController, parentDelegte: self)
        childCoordinators.append(child)
        child.start()
    }
    
    func amrapSelected() {
        let child = AMRAPCoordinator(navigationController: navigationController, parentDelegate: self)
        childCoordinators.append(child)
        child.start()
    }
    
    func emomSelected() {
        let child = EMOMCoordinator(navigationController: navigationController, parentDelegate: self)
        childCoordinators.append(child)
        child.start()
    }
}

// MARK: - Live Display Flow
extension LiveWorkoutCoordinator: LiveWorkoutDisplayFlow {
    
    func liveWorkoutCompleted() {
        // currently not used
        // TODO: - implement properly
        //let vc = WorkoutCompletedViewController.instantiate()
        //navigationController.pushViewController(vc, animated: true)
    }
    func addSet(_ exercise: exercise) {
        let vc = NewRepsViewController()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - EMOM Creation Delegate
extension LiveWorkoutCoordinator: EmomParentDelegate {
    func finishedCreatingEMOM(emomModel: EMOM) {
        DisplayWorkoutViewController.selectedWorkout.exercises?.append(emomModel)
        // line to update database
        FirebaseLiveWorkoutUpdater.shared.update(DisplayWorkoutViewController.selectedWorkout)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: DisplayWorkoutViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
}

// MARK: - AMRAP Creation Delegate
extension LiveWorkoutCoordinator: AmrapParentDelegate {
    func finishedCreatingAMRAP(amrapModel: AMRAP) {
        DisplayWorkoutViewController.selectedWorkout.exercises?.append(amrapModel)
        // line to update database
        FirebaseLiveWorkoutUpdater.shared.update(DisplayWorkoutViewController.selectedWorkout)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: DisplayWorkoutViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
}

// MARK: - Circuit Creation Flow
extension LiveWorkoutCoordinator: CircuitParentDelegate {
    func finishedCreatingCircuit(circuitModel: circuit) {
        DisplayWorkoutViewController.selectedWorkout.exercises?.append(circuitModel)
        // line to update database
        FirebaseLiveWorkoutUpdater.shared.update(DisplayWorkoutViewController.selectedWorkout)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: DisplayWorkoutViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
}

extension LiveWorkoutCoordinator: WorkoutDisplayCoordinatorDelegate {
    func showCompletedPage() {
        // not implemented
    }
}
