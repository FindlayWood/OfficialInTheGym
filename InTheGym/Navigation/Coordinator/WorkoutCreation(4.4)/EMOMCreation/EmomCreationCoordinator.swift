//
//  EmomCreationCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class EmomCreationCoordinator: NSObject, Coordinator {
    
    var exerciseAddedPublisher: PassthroughSubject<ExerciseModel,Never>?
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var publisher: PassthroughSubject<EMOMModel,Never>?
    
    init(navigationController: UINavigationController, publisher: PassthroughSubject<EMOMModel,Never>?) {
        self.navigationController = navigationController
        self.publisher = publisher
    }
    
    func start() {
        let vc = CreateEMOMViewController()
        vc.coordinator = self
        vc.viewModel.completedPublisher = publisher
        navigationController.pushViewController(vc, animated: true)
    }
}

extension EmomCreationCoordinator {
    func showTimePicker(with delegate: TimeSelectionParentDelegate, time: Int) {
        let child = TimeSelectionPickerCoordinator(navigationController: navigationController, parent: delegate, currentTime: time)
        childCoordinators.append(child)
        child.start()
    }
}

extension EmomCreationCoordinator {
    func addNewExercise(_ exercise: ExerciseModel) {
        let vc = ExerciseSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// exercise selection
extension EmomCreationCoordinator: ExerciseSelectionFlow {
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
extension EmomCreationCoordinator: RepSelectionFlow {
    func repsSelected(_ exercise: ExerciseModel) {
        let vc = WeightSelectionViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// weight selection
extension EmomCreationCoordinator: WeightSelectionFlow {
    func weightSelected(_ exercise: ExerciseModel) {
        let vc = AddMoreToExerciseViewController()
        vc.viewModel.exercise = exercise
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
// finish
extension EmomCreationCoordinator: FinishedExerciseCreationFlow {
    func finishedExercise(_ exercise: ExerciseModel) {
        exerciseAddedPublisher?.send(exercise)
        let viewControllers = navigationController.viewControllers
        for viewController in viewControllers {
            if viewController.isKind(of: CreateEMOMViewController.self) {
                navigationController.popToViewController(viewController, animated: true)
                break
            }
        }
    }
}
// completed circuit
extension EmomCreationCoordinator {
    func completedEmom() {
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
extension EmomCreationCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
        
        if let timeViewController = fromViewController as? TimeSelectionViewController {
            childDidFinish(timeViewController.coordinator)
        }
    }
}


