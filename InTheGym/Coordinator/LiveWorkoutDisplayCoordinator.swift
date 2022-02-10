//
//  LiveWorkoutDisplayCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class LiveWorkoutDisplayCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var workout: WorkoutModel
    
    init(navigationController: UINavigationController, workout: WorkoutModel) {
        self.navigationController = navigationController
        self.workout = workout
    }
    
    func start() {
        let vc = LiveWorkoutDisplayViewController()
        vc.viewModel.workoutModel = workout
        vc.hidesBottomBarWhenPushed = true
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Methods
extension LiveWorkoutDisplayCoordinator {
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
    
    func addExercise(_ adding: ExerciseAdding, workoutPosition: Int) {
        let child = LiveExerciseSelectionCoordinator(navigationController: navigationController, creationViewModel: adding, workoutPosition: workoutPosition)
        childCoordinators.append(child)
        child.start()
    }
    func addSet(_ exerciseViewModel: ExerciseCreationViewModel) {
        let child = RepsSelectionCoordinator(navigationController: navigationController, exerciseViewModel: exerciseViewModel)
        childCoordinators.append(child)
        child.start()
    }
    func addClip(for exercise: ExerciseModel, _ workout: WorkoutModel, on delegate: ClipAdding) {
        let child = ClipCoordinator(navigationController: navigationController, workout: workout, exercise: exercise, addingDelegate: delegate)
        childCoordinators.append(child)
        child.start()
    }
}
