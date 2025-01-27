//
//  RegularWorkoutCreationCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class RegularWorkoutCreationCoordinator: Coordinator {
    
    /// the publisher to publish the exercise when it is completed
    var completedExercise: PassthroughSubject<ExerciseModel,Never>?
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var assignTo: Users?
    var subscriptionManager: PurchaseManager
    
    init(navigationController: UINavigationController, assignTo: Users?, subscriptionManager: PurchaseManager) {
        self.navigationController = navigationController
        self.assignTo = assignTo
        self.subscriptionManager = subscriptionManager
    }
    
    func start() {
        let vc = WorkoutCreationViewController()
        vc.coordinator = self
        vc.viewModel.assignTo = assignTo
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
extension RegularWorkoutCreationCoordinator {
    func addNewExercise(_ exercise: ExerciseModel) {
        let vc = ExerciseSelectionViewController()
        vc.coordinator = self
        vc.viewModel.exercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    func workoutOptions(_ model: WorkoutCreationOptionsNavigationModel) {
        let child = WorkoutCreationOptionsCoordinator(navigationController: navigationController, navigationModel: model)
        childCoordinators.append(child)
        child.start()
    }
}
// Exercise Selection Flow
extension RegularWorkoutCreationCoordinator: ExerciseSelectionFlow {
    func exerciseSelected(_ exercise: ExerciseModel) {
        let vc = SetSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    func otherSelected(_ exercise: ExerciseModel) {
        let vc = OtherExerciseViewController()
        vc.viewModel.exerciseModel = exercise
        vc.coordinator = self
        navigationController.present(vc, animated: true)
    }
    func infoSelected(_ discoverModel: DiscoverExerciseModel) {
        let child = ExerciseDiscoveryCoordinator(navigationController: navigationController, exercise: discoverModel, subscriptionManager: subscriptionManager)
        childCoordinators.append(child)
        child.start()
    }
}
// Sets Selection Flow
extension RegularWorkoutCreationCoordinator: SetSelectionFlow {
    func setSelected(_ exercise: ExerciseModel) {
        let vc = RepSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// Reps Selection Flow
extension RegularWorkoutCreationCoordinator: RepSelectionFlow {
    func repsSelected(_ exercise: ExerciseModel) {
        let vc = WeightSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// Weight Selection Flow
extension RegularWorkoutCreationCoordinator: WeightSelectionFlow {
    func weightSelected(_ exercise: ExerciseModel) {
        let vc = AddMoreToExerciseViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// Finished
extension RegularWorkoutCreationCoordinator: FinishedExerciseCreationFlow {
    func finishedExercise(_ exercise: ExerciseModel) {
        completedExercise?.send(exercise)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for viewController in viewControllers {
            if viewController.isKind(of: WorkoutCreationViewController.self) {
                navigationController.popToViewController(viewController, animated: true)
                break
            }
        }
    }
}
