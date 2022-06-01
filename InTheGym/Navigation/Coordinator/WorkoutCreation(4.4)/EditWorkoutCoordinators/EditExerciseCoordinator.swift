//
//  EditExerciseCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class EditExerciseCoordinator: Coordinator {
    // MARK: - Publisher
    /// send exercise back to listener in view model
    var editComplete: PassthroughSubject<ExerciseModel,Never>?
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var exercise: ExerciseModel
    var setNumber: Int
    // MARK: - Initializer
    init(navigationController: UINavigationController, exercise: ExerciseModel, publisher: PassthroughSubject<ExerciseModel,Never>, setNumber: Int) {
        self.navigationController = navigationController
        self.exercise = exercise
        self.editComplete = publisher
        self.setNumber = setNumber - 1 /// must minus 1 as data sources are 0 indexed
    }
    // MARK: - Start
    func start() {
        let vc = RepSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        vc.viewModel.editingSet = setNumber
        vc.viewModel.isEditing = true
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Flow
// Reps Selection Flow
extension EditExerciseCoordinator: RepSelectionFlow {
    func repsSelected(_ exercise: ExerciseModel) {
        let vc = WeightSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        vc.viewModel.editingSet = setNumber
        vc.viewModel.isEditing = true
        navigationController.pushViewController(vc, animated: true)
    }
}
// Weight Selection Flow
extension EditExerciseCoordinator: WeightSelectionFlow {
    func weightSelected(_ exercise: ExerciseModel) {
        let vc = AddMoreToExerciseViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        vc.viewModel.editingSet = setNumber
        vc.viewModel.isEditing = true
        navigationController.pushViewController(vc, animated: true)
    }
}
// Finished
extension EditExerciseCoordinator: FinishedExerciseCreationFlow {
    func finishedExercise(_ exercise: ExerciseModel) {
        editComplete?.send(exercise)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for viewController in viewControllers {
            if viewController.isKind(of: WorkoutDisplayViewController.self) {
                navigationController.popToViewController(viewController, animated: true)
                break
            }
        }
    }
}
