//
//  LiveWorkoutDisplayCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class LiveWorkoutDisplayCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var modalNavigationController: UINavigationController?
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
    
    func addExercise(_ exercise: ExerciseModel, publisher: PassthroughSubject<ExerciseModel,Never>) {
        let child = LiveWorkoutExerciseCreationCoordinator(navigationController: navigationController, exercise: exercise, publisher: publisher)
        childCoordinators.append(child)
        child.start()
    }
    func addSet(_ exercise: ExerciseModel, publisher: PassthroughSubject<ExerciseModel,Never>) {
        let child = LiveWorkoutSetCreationCoordinator(navigationController: navigationController, exercise: exercise, publisher: publisher)
        childCoordinators.append(child)
        child.start()
    }
    func addClip(for exercise: ExerciseModel, _ workout: WorkoutModel, on delegate: ClipAdding) {
        let child = ClipCoordinator(navigationController: navigationController, workout: workout, exercise: DiscoverExerciseModel(exerciseName: exercise.exercise), addingDelegate: delegate)
        childCoordinators.append(child)
        child.start()
    }
    func viewClip(_ clipModel: WorkoutClipModel, fromViewControllerDelegate: CustomAnimatingClipFromVC) {
        let keyClipModel = KeyClipModel(clipKey: clipModel.clipKey, storageURL: clipModel.storageURL)
        let child = ClipProfileCustomCoordinator(navigationController: navigationController, clipModel: keyClipModel, fromViewControllerDelegate: fromViewControllerDelegate)
        childCoordinators.append(child)
        child.start()
    }
    func showDescriptions(for exercise: ExerciseModel) {
        let child = ExerciseDiscoveryCoordinator(navigationController: navigationController, exercise: exercise)
        childCoordinators.append(child)
        child.start()
    }
}
extension LiveWorkoutDisplayCoordinator {
    func complete(_ workout: WorkoutModel) {
        let child = CompletedWorkoutCoordinator(navigationController: navigationController, workoutModel: workout)
        childCoordinators.append(child)
        child.start()
    }
}
