//
//  WorkoutDisplayCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import Combine

class WorkoutDisplayCoordinator: NSObject, Coordinator {
    // MARK: - Coordinators
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var modalNavigationController: UINavigationController?
    var workout: WorkoutModel
    // MARK: - Initializer
    init(navigationController: UINavigationController, workout: WorkoutModel) {
        self.navigationController = navigationController
        self.workout = workout
    }
    // MARK: - Start
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
        let child = CompletedWorkoutCoordinator(navigationController: navigationController, workoutModel: workout)
        childCoordinators.append(child)
        child.start()
    }
    func showEMOM(_ emom: EMOMModel, _ workout: WorkoutModel) {
        let vc = DisplayEMOMViewController()
        vc.viewModel.emomModel = emom
        vc.viewModel.workoutModel = workout
        navigationController.pushViewController(vc, animated: true)
    }
    func showCircuit(_ circuit: CircuitModel, _ workout: WorkoutModel, _ publisher: PassthroughSubject<CircuitModel,Never>) {
        let child = DisplayCircuitCoordinator(navigationController: navigationController, circuitModel: circuit, workoutModel: workout, publisher: publisher)
        childCoordinators.append(child)
        child.start()
//        let vc = DisplayCircuitViewController()
//        vc.viewModel.circuitModel = circuit
//        vc.viewModel.workoutModel = workout
//        navigationController.pushViewController(vc, animated: true)
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
    func showDescriptions(_ exercise: DiscoverExerciseModel) {
        let child = ExerciseDiscoveryCoordinator(navigationController: navigationController, exercise: exercise)
        childCoordinators.append(child)
        child.start()
    }
    func viewClip(_ clipModel: WorkoutClipModel, fromViewControllerDelegate: CustomAnimatingClipFromVC) {
        let keyClipModel = KeyClipModel(clipKey: clipModel.clipKey, storageURL: clipModel.storageURL)
        let child = ClipProfileCustomCoordinator(navigationController: navigationController, clipModel: keyClipModel, fromViewControllerDelegate: fromViewControllerDelegate)
        childCoordinators.append(child)
        child.start()
    }
    func showSingleSet(fromViewControllerDelegate: AnimatingSingleSet, setModel: ExerciseSet, editAction: PassthroughSubject<ExerciseSet,Never>? = nil, isEditable: Bool? = false) {
        let child = SingleSetCoordinator(navigationController: navigationController, fromViewControllerDelegate: fromViewControllerDelegate, setModel: setModel, editAction: editAction, isEditable: isEditable)
        childCoordinators.append(child)
        child.start()
    }
    func editSet(exerciseModel: ExerciseModel, publisher: PassthroughSubject<ExerciseModel,Never>, setNumber: Int) {
        let child = EditExerciseCoordinator(navigationController: navigationController, exercise: exerciseModel, publisher: publisher, setNumber: setNumber)
        childCoordinators.append(child)
        child.start()
    }
}
