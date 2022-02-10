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
        navigationController.pushViewController(vc, animated: true)
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
        let child = ClipCoordinator(navigationController: navigationController, workout: workout, exercise: exercise, addingDelegate: delegate)
        childCoordinators.append(child)
        child.start()
    }
}
