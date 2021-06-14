//
//  CreatingWorkoutCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol CreationDelegate: AnyObject {
    func bodyTypeSelected(_ exercise: exercise)
    func exerciseSelected(_ exercise: exercise)
    func repsSelected(_ exercise: exercise)
}

protocol RegularWorkoutFlow: RegularDelegate {
    func addExercise(_ exercise: exercise)
    func addCircuit()
    func addAMRAP()
    func noteAdded(_ exercise: exercise)
}

protocol LiveWorkoutFlow: LiveDelegate {
    func addExercise(_ exercise: exercise)
    func addSet(_ exercise: exercise)
}

protocol CircuitFlow: CircuitDelegate {
    func addExercise(_ circuit: exercise)
}

protocol AMRAPFlow: CreationDelegate {
    func addExercise(_ exercise: exercise)
}

protocol RegularAndCircuitFlow: AnyObject {
    func setsSelected(_ exercise: exercise)
}

protocol RegularAndLiveFlow: AnyObject {
    func weightSelected(_ exercise: exercise)
}

typealias RegularDelegate = CreationDelegate & RegularAndCircuitFlow & RegularAndLiveFlow
typealias LiveDelegate = CreationDelegate & RegularAndLiveFlow & WorkoutDisplayCoordinator
typealias CircuitDelegate = CreationDelegate & RegularAndCircuitFlow


class RegularWorkoutCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigationController.delegate = self
        let vc = AddWorkoutHomeViewController.instantiate()
        AddWorkoutHomeViewController.groupBool = false
        vc.coordinator = self
        vc.playerBool = true
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

extension RegularWorkoutCoordinator: RegularWorkoutFlow {
    
    func addCircuit() {
        let child = CircuitCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
    }
    
    func addAMRAP() {
        let child = AMRAPCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
    }
    
    func addExercise(_ exercise: exercise) {
        let vc = BodyTypeViewController.instantiate()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func bodyTypeSelected(_ exercise: exercise) {
        let vc = ExerciseViewController.instantiate()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func exerciseSelected(_ exercise: exercise) {
        let vc = ExerciseSetsViewController.instantiate()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func setsSelected(_ exercise: exercise) {
        let vc = NewRepsViewController.instantiate()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func repsSelected(_ exercise: exercise) {
        let vc = NewWeightViewController.instantiate()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func weightSelected(_ exercise: exercise) {
        let vc = NoteViewController.instantiate()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func noteAdded(_ exercise: exercise) {
        let object = exercise.toObject()
        print(object)
        AddWorkoutHomeViewController.exercises.append(object)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: AddWorkoutHomeViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
}

//MARK: - Navigation Delegate Method
extension RegularWorkoutCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
        
        if let circuitViewController = fromViewController as? CreateCircuitViewController {
            childDidFinish(circuitViewController.coordinator)
        }
    }
}

