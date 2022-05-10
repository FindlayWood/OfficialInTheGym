//
//  CreatingWorkoutCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol CreationFlow: AnyObject {
    func addExercise(_ exercise: exercise)
    func exerciseSelected(_ exercise: exercise)
    func otherSelected(_ exercise: exercise)
    func repsSelected(_ exercise: exercise)
    func weightSelected(_ exercise: exercise)
    func completeExercise()
}

protocol RegularCreationFlow: CreationFlow {
    func goToUploadPage(with uploadable: UploadableWorkout)
}

protocol LiveWorkoutDisplayFlow: AnyObject {
    func liveWorkoutCompleted()
    func addSet(_ exercise: exercise)
}

protocol CircuitFlow: AnyObject {
    func addExercise(_ circuit: exercise)
}

protocol AMRAPFlow: AnyObject {
    func addExercise(_ exercise: exercise)
}

protocol EMOMFlow: AnyObject {
    func addExercise(_ exercise: exercise)
}

protocol RegularAndCircuitFlow: AnyObject {
    func setsSelected(_ exercise: exercise)
}

protocol RegularAndLiveFlow: AnyObject {
    func circuitSelected()
    func amrapSelected()
    func emomSelected()
}

protocol EmomParentDelegate: AnyObject {
    func finishedCreatingEMOM(emomModel: EMOM)
}
protocol AmrapParentDelegate: AnyObject {
    func finishedCreatingAMRAP(amrapModel: AMRAP)
}
protocol CircuitParentDelegate: AnyObject {
    func finishedCreatingCircuit(circuitModel: circuit)
}



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
        let vc = AddWorkoutHomeViewController.instantiate()
        AddWorkoutHomeViewController.groupBool = false
        vc.coordinator = self
        vc.playerBool = true
        vc.assignee = assignTo
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Regular Creation Flow
extension RegularWorkoutCoordinator: RegularCreationFlow {
    
    func goToUploadPage(with uploadable: UploadableWorkout) {
        let child = UploadingCoordinator(navigationController: navigationController, workoutToUpload: uploadable)
        childCoordinators.append(child)
        child.start()
    }
}

// MARK: - Creation Flow
extension RegularWorkoutCoordinator: CreationFlow {
    
    func addExercise(_ exercise: exercise) {
        if #available(iOS 13, *) {
            let vc = ExerciseSelectionViewController()
//            vc.coordinator = self
//            vc.newExercise = exercise
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func exerciseSelected(_ exercise: exercise) {
        let vc = SetSelectionViewController()
//        vc.coordinator = self
//        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
    
    func otherSelected(_ exercise: exercise) {
        let vc = OtherExerciseViewController()
        vc.newExercise = exercise
        vc.coordinator = self
        navigationController.present(vc, animated: true, completion: nil)
    }
    
    func repsSelected(_ exercise: exercise) {
        let vc = WeightSelectionViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func weightSelected(_ exercise: exercise) {
//        childCoordinator = AddMoreToExerciseCoordinator(navigationController: navigationController, creationViewModel: <#T##ExerciseCreationViewModel#>)
//        childCoordinators.append(childCoordinator)
//        childCoordinator.parentCoordinator = self
//        childCoordinator.start()
    }
    
    func completeExercise() {
        childDidFinish(childCoordinator)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: AddWorkoutHomeViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
}

// MARK: - Regular and Live Flow
extension RegularWorkoutCoordinator: RegularAndLiveFlow {
    func circuitSelected() {
        let child = CircuitCoordinator(navigationController: navigationController, parentDelegte: self)
        childCoordinators.append(child)
        child.start()
    }
    
    func amrapSelected() {
        let child = AMRAPCoordinator(navigationController: navigationController, parentDelegate: self)
        childCoordinators.append(child)
        child.start()
    }
    
    func emomSelected() {
        let child = EMOMCoordinator(navigationController: navigationController, parentDelegate: self)
        childCoordinators.append(child)
        child.start()
    }
}

// MARK: - Regular and Circuit Flow
extension RegularWorkoutCoordinator: RegularAndCircuitFlow {
    func setsSelected(_ exercise: exercise) {
        let vc = RepSelectionViewController()
//        vc.coordinator = self
//        vc.newExercise = exercise
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - EMOM Creation Delegate
extension RegularWorkoutCoordinator: EmomParentDelegate {
    func finishedCreatingEMOM(emomModel: EMOM) {
        let emomObject = emomModel.toObject()
        AddWorkoutHomeViewController.exercises.append(emomObject)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: AddWorkoutHomeViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }        
    }
}

// MARK: - AMRAP Creation Delegate
extension RegularWorkoutCoordinator: AmrapParentDelegate {
    func finishedCreatingAMRAP(amrapModel: AMRAP) {
        let amrapObject = amrapModel.toObject()
        AddWorkoutHomeViewController.exercises.append(amrapObject)
        let viewControllers: [UIViewController] = navigationController.viewControllers as [UIViewController]
        for controller in viewControllers {
            if controller.isKind(of: AddWorkoutHomeViewController.self) {
                navigationController.popToViewController(controller, animated: true)
                break
            }
        }
    }
}

// MARK: - Circuit Creation Flow
extension RegularWorkoutCoordinator: CircuitParentDelegate {
    func finishedCreatingCircuit(circuitModel: circuit) {
        let circuitObject = circuitModel.toObject()
        AddWorkoutHomeViewController.exercises.append(circuitObject)
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

