//
//  WorkoutDisplayCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class WorkoutDisplayCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var workout: WorkoutModel
    
    init(navigationController: UINavigationController, workout: WorkoutModel) {
        self.navigationController = navigationController
        self.workout = workout
    }
    
    func start() {
        let vc = WorkoutDisplayViewController()
        vc.viewModel.workout = workout
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Methods
extension WorkoutDisplayCoordinator {
    func complete(_ workout: WorkoutModel) {
        let vc = CompletedWorkoutPageViewController()
        vc.viewModel.workout = workout
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    func completedUpload() {
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: DisplayingWorkoutsViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
    func showEMOM(_ emom: EMOMModel, _ workout: WorkoutModel) {
        let vc = DisplayEMOMViewController()
        vc.viewModel.emomModel = emom
        vc.viewModel.workoutModel = workout
        navigationController.pushViewController(vc, animated: true)
    }
    func showCircuit(_ circuit: CircuitModel, _ workout: WorkoutModel) {
        let vc = DisplayCircuitViewController()
        vc.viewModel.circuitModel = circuit
        vc.viewModel.workoutModel = workout
        navigationController.pushViewController(vc, animated: true)
    }
    func showAMRAP(_ amrap: AMRAPModel, _ workout: WorkoutModel) {
        let vc = DisplayAMRAPViewController()
        vc.viewModel.amrapModel = amrap
        vc.viewModel.workoutModel = workout
        navigationController.pushViewController(vc, animated: true)
    }
    func addClip(for exercise: ExerciseModel, _ workout: WorkoutModel, on delegate: ClipAdding) {
        let child = ClipCoordinator(navigationController: navigationController, workout: workout, exercise: DiscoverExerciseModel(exerciseName: exercise.exercise), addingDelegate: delegate)
        childCoordinators.append(child)
        child.start()
    }
    func showDescriptions(_ exercise: ExerciseModel) {
        let vc = ExerciseDescriptionViewController()
        vc.viewModel.exercise = DiscoverExerciseModel(exerciseName: exercise.exercise)
        navigationController.pushViewController(vc, animated: true)
    }
    func viewClip(_ clipModel: WorkoutClipModel) {
        let keyClipModel = KeyClipModel(clipKey: clipModel.clipKey, storageURL: clipModel.storageURL)
        let vc = ViewClipViewController()
        vc.viewModel.keyClipModel = keyClipModel
        navigationController.present(vc, animated: true, completion: nil)
    }
}
