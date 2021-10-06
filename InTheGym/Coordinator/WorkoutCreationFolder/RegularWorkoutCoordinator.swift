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
    func otherSelected(_ exercise: exercise)
    func exerciseSelected(_ exercise: exercise)
    func repsSelected(_ exercise: exercise)
    func weightSelected(_ exercise: exercise)
    func upload()
}

protocol RegularWorkoutFlow: RegularDelegate {
    func addExercise(_ exercise: exercise)
    func addCircuit()
    func addAMRAP()
    func addEMOM()
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

protocol EMOMFlow: CreationDelegate {
    func addExercise(_ exercise: exercise)
}

protocol RegularAndCircuitFlow: AnyObject {
    func setsSelected(_ exercise: exercise)
}

protocol RegularAndLiveFlow: AnyObject {
    func weightSelected(_ exercise: exercise)
}

typealias RegularDelegate = CreationDelegate & RegularAndCircuitFlow
typealias LiveDelegate = CreationDelegate & WorkoutDisplayCoordinator
typealias CircuitDelegate = CreationDelegate & RegularAndCircuitFlow


class RegularWorkoutCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var childCoordinator: AddMoreToExerciseCoordinator!
    var assignTo: Assignable
    
    init(navigationController: UINavigationController, assignTo: Assignable) {
        self.navigationController = navigationController
        self.assignTo = assignTo
    }
    
    func start() {
        navigationController.delegate = self
//        let vc = DisplayWorkoutViewController.instantiate()
//        let newWorkout = CreatingNewWorkout()
//        newWorkout.title = "New Workout Title"
//        newWorkout.exercises = [WorkoutType]()
//        DisplayWorkoutViewController.selectedWorkout = newWorkout
//        vc.coordinator = self
//        navigationController.pushViewController(vc, animated: true)
        let vc = AddWorkoutHomeViewController.instantiate()
        AddWorkoutHomeViewController.groupBool = false
        vc.coordinator = self
        vc.playerBool = true
        vc.assignee = assignTo
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
    
    func addEMOM() {
        let child = EMOMCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
    }
    
    func addExercise(_ exercise: exercise) {
        if #available(iOS 13, *) {
            let vc = ExerciseSelectionViewController()
            vc.coordinator = self
            vc.newExercise = exercise
            navigationController.pushViewController(vc, animated: true)
        }
        //vc.coordinator = self
        //vc.newExercise = exercise
        
    }
    
    func bodyTypeSelected(_ exercise: exercise) {
        let vc = ExerciseViewController.instantiate()
        vc.coordinator = self
        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func otherSelected(_ exercise: exercise) {
        let vc = OtherExerciseViewController()
        vc.newExercise = exercise
        vc.coordinator = self
        navigationController.present(vc, animated: true, completion: nil)
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
        childCoordinator = AddMoreToExerciseCoordinator(navigationController: navigationController, exercise)
        childCoordinators.append(childCoordinator)
        childCoordinator.parentCoordinator = self
        childCoordinator.start()
        
//        let vc = NoteViewController.instantiate()
//        vc.coordinator = self
//        vc.newExercise = exercise
//        navigationController.pushViewController(vc, animated: true)
    }
    
    func noteAdded(_ exercise: exercise) {
        let object = exercise.toObject()
        AddWorkoutHomeViewController.exercises.append(object)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: AddWorkoutHomeViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
    func upload() {
        childDidFinish(childCoordinator)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: AddWorkoutHomeViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
//            if controller.isKind(of: DisplayWorkoutViewController.self) {
//                navigationController.popToViewController(controller, animated: true)
//                break
//            }
        }
    }
    func goToUploadPage(_ uploadable: UploadableWorkout) {
        let child = UploadingCoordinator(navigationController: navigationController, workoutToUpload: uploadable)
        childCoordinators.append(child)
        child.start()
    }
}

extension RegularWorkoutCoordinator: WorkoutDisplayCoordinator {
    func showCompletedPage() {
        
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

