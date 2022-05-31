//
//  LiveWorkoutCreationCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class LiveWorkoutExerciseCreationCoordinator: Coordinator {
    
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
        let vc = ExerciseSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// Exercise Selection Flow
extension LiveWorkoutExerciseCreationCoordinator: ExerciseSelectionFlow {
    func exerciseSelected(_ exercise: ExerciseModel) {
        completedExercise?.send(exercise)
        let viewControllers = navigationController.viewControllers
        for viewController in viewControllers {
            if viewController.isKind(of: LiveWorkoutDisplayViewController.self) {
                navigationController.popToViewController(viewController, animated: true)
                break
            }
        }
    }
    func otherSelected(_ exercise: ExerciseModel) {
        let vc = OtherExerciseViewController()
        vc.viewModel.exerciseModel = exercise
        vc.coordinator = self
        navigationController.present(vc, animated: true)
    }
    func infoSelected(_ discoverModel: DiscoverExerciseModel) {
        let child = ExerciseDiscoveryCoordinator(navigationController: navigationController, exercise: discoverModel)
        childCoordinators.append(child)
        child.start()
    }
    func addCircuit() {
        
    }
    func addAmrap() {
        
    }
    func addEmom() {
        
    }
}
