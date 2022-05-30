//
//  CircuitCreationCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CircuitCreationCoordinator: NSObject, Coordinator {
    
    var exerciseAddedPublisher: PassthroughSubject<ExerciseModel,Never>?
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var publisher: PassthroughSubject<CircuitModel,Never>?
    
    init(navigationController: UINavigationController, publisher: PassthroughSubject<CircuitModel,Never>?) {
        self.navigationController = navigationController
        self.publisher = publisher
    }
    
    func start() {
        let vc = CreateCircuitViewController()
        vc.coordinator = self
        vc.viewModel.completedPublisher = publisher
        navigationController.pushViewController(vc, animated: true)
    }
}
extension CircuitCreationCoordinator {
    func addNewExercise(_ exercise: ExerciseModel) {
        let vc = ExerciseSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// exercise selection
extension CircuitCreationCoordinator: ExerciseSelectionFlow {
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
// Set Selection
extension CircuitCreationCoordinator: SetSelectionFlow {
    func setSelected(_ exercise: ExerciseModel) {
        let vc = RepSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// reps selection
extension CircuitCreationCoordinator: RepSelectionFlow {
    func repsSelected(_ exercise: ExerciseModel) {
        let vc = WeightSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// weight selection
extension CircuitCreationCoordinator: WeightSelectionFlow {
    func weightSelected(_ exercise: ExerciseModel) {
        let vc = AddMoreToExerciseViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// finish
extension CircuitCreationCoordinator: FinishedExerciseCreationFlow {
    func finishedExercise(_ exercise: ExerciseModel) {
        exerciseAddedPublisher?.send(exercise)
        let viewControllers = navigationController.viewControllers
        for viewController in viewControllers {
            if viewController.isKind(of: CreateCircuitViewController.self) {
                navigationController.popToViewController(viewController, animated: true)
                break
            }
        }
    }
}
// completed circuit
extension CircuitCreationCoordinator {
    func completedCircuit() {
        let viewController = navigationController.viewControllers
        for viewController in viewController {
            if viewController.isKind(of: WorkoutCreationViewController.self) {
                navigationController.popToViewController(viewController, animated: true)
                break
            }
        }
    }
}


//MARK: - Navigation Delegate Method
extension CircuitCreationCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
        
    }
}

