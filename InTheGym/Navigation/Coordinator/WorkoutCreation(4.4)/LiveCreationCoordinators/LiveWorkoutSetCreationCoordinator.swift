//
//  LiveWorkoutSetCreationCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class LiveWorkoutSetCreationCoordinator: Coordinator {
    
    var completedExercise: PassthroughSubject<ExerciseModel,Never>?
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var exercise: ExerciseModel
    
    init(navigationController: UINavigationController, exercise: ExerciseModel, publisher: PassthroughSubject<ExerciseModel,Never>) {
        self.navigationController = navigationController
        self.exercise = exercise
        self.completedExercise = publisher
    }
    
    func start() {
        let vc = RepSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// Reps Selection Flow
extension LiveWorkoutSetCreationCoordinator: RepSelectionFlow {
    func repsSelected(_ exercise: ExerciseModel) {
        let vc = WeightSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// Weight Selection Flow
extension LiveWorkoutSetCreationCoordinator: WeightSelectionFlow {
    func weightSelected(_ exercise: ExerciseModel) {
        let vc = AddMoreToExerciseViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// Finished
extension LiveWorkoutSetCreationCoordinator: FinishedExerciseCreationFlow {
    func finishedExercise(_ exercise: ExerciseModel) {
        completedExercise?.send(exercise)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for viewController in viewControllers {
            if viewController.isKind(of: LiveWorkoutDisplayViewController.self) {
                navigationController.popToViewController(viewController, animated: true)
                break
            }
        }
    }
}
