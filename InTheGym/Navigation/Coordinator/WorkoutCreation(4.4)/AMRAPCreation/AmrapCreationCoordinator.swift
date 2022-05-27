//
//  CircuitCreationCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class AMRAPCreationCoordinator: NSObject, Coordinator {
    
    var exerciseAddedPublisher: PassthroughSubject<ExerciseModel,Never>?
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var publisher: PassthroughSubject<AMRAPModel,Never>?
    
    init(navigationController: UINavigationController, publisher: PassthroughSubject<AMRAPModel,Never>?) {
        self.navigationController = navigationController
        self.publisher = publisher
    }
    
    func start() {
        let vc = CreateAMRAPViewController()
        vc.coordinator = self
        vc.viewModel.completedPublisher = publisher
        navigationController.pushViewController(vc, animated: true)
    }
}
extension AMRAPCreationCoordinator {
    func addNewExercise(_ exercise: ExerciseModel) {
        let vc = ExerciseSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    func showTimePicker(with delegate: TimeSelectionParentDelegate, time: Int) {
        let child = TimeSelectionPickerCoordinator(navigationController: navigationController, parent: delegate, currentTime: time)
        childCoordinators.append(child)
        child.start()
    }
}
// exercise selection
extension AMRAPCreationCoordinator: ExerciseSelectionFlow {
    func exerciseSelected(_ exercise: ExerciseModel) {
        let vc = RepSelectionViewController()
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
    func addCircuit() {
        
    }
    func addAmrap() {
        
    }
    func addEmom() {
        
    }
}
// reps selection
extension AMRAPCreationCoordinator: RepSelectionFlow {
    func repsSelected(_ exercise: ExerciseModel) {
        let vc = WeightSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// weight selection
extension AMRAPCreationCoordinator: WeightSelectionFlow {
    func weightSelected(_ exercise: ExerciseModel) {
        let vc = AddMoreToExerciseViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// finish
extension AMRAPCreationCoordinator: FinishedExerciseCreationFlow {
    func finishedExercise(_ exercise: ExerciseModel) {
        exerciseAddedPublisher?.send(exercise)
        let viewControllers = navigationController.viewControllers
        for viewController in viewControllers {
            if viewController.isKind(of: CreateAMRAPViewController.self) {
                navigationController.popToViewController(viewController, animated: true)
                break
            }
        }
    }
}
// completed circuit
extension AMRAPCreationCoordinator {
    func completedAmrap() {
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
extension AMRAPCreationCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
        
    }
}

