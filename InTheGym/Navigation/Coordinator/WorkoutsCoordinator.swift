//
//  WorkoutsCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol WorkoutsFlow: AnyObject {
    func addNewWorkout(_ assignTo: Users?)
    func addLiveWorkout()
    func addSavedWorkout()
}

class WorkoutsCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController.navigationBar.shadowImage = UIImage()
        self.navigationController.navigationBar.tintColor = .white
    }
    
    func start() {
        let vc = DisplayingWorkoutsViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}

//MARK: - Flow Methods
extension WorkoutsCoordinator: WorkoutsFlow {

    func plusPressed() {
        let vc = NewWorkoutSelectionViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addNewWorkout(_ assignTo: Users?) {
        let child = RegularWorkoutCreationCoordinator(navigationController: navigationController, assignTo: assignTo)
        childCoordinators.append(child)
        child.start()
    }
    func addProgram() {
        let child = MyProgramsCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
    }

    
    func addLiveWorkout() {
        let vc = PreLiveWorkoutViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addSavedWorkout() {
        let child = RegularWorkoutCreationCoordinator(navigationController: navigationController, assignTo: nil)
        childCoordinators.append(child)
        child.start()
    }
    
}


//MARK: - Child Coordinators
extension WorkoutsCoordinator {
    func show(_ workout: WorkoutModel) {
        let child = WorkoutDisplayCoordinator(navigationController: navigationController, workout: workout)
        childCoordinators.append(child)
        child.start()
    }
    func showLiveWorkout(_ workout: WorkoutModel) {
        let child = LiveWorkoutDisplayCoordinator(navigationController: navigationController, workout: workout)
        childCoordinators.append(child)
        child.start()
    }
}


//MARK: - Navigation Delegate Method
extension WorkoutsCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }
        
        if navigationController.viewControllers.contains(fromViewController){
            return
        }
        
        if let PublicViewController = fromViewController as? PublicTimelineViewController {
            childDidFinish(PublicViewController.coordinator)
        }
    }
}
