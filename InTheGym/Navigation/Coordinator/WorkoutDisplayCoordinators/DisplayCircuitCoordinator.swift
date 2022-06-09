//
//  DisplayCircuitCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class DisplayCircuitCoordinator: Coordinator{
    // MARK: - Properties
    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController
    var circuitModel: CircuitModel
    var workoutModel: WorkoutModel
    var publisher: PassthroughSubject<CircuitModel,Never>
    // MARK: - Initializer
    init(navigationController: UINavigationController, circuitModel: CircuitModel, workoutModel: WorkoutModel, publisher: PassthroughSubject<CircuitModel,Never>) {
        self.navigationController = navigationController
        self.circuitModel = circuitModel
        self.workoutModel = workoutModel
        self.publisher = publisher
    }
    // MARK: - Start
    func start() {
        let vc = DisplayCircuitViewController()
        vc.viewModel.circuitModel = circuitModel
        vc.viewModel.workoutModel = workoutModel
        vc.viewModel.updatedCircuitPublisher = publisher
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// MARK: - Flow
extension DisplayCircuitCoordinator {
    func showExerciseDiscovery(_ discoverModel: DiscoverExerciseModel) {
        let child = ExerciseDiscoveryCoordinator(navigationController: navigationController, exercise: discoverModel)
        childCoordinators.append(child)
        child.start()
    }
    func completed() {
        navigationController.popViewController(animated: true)
    }
}
