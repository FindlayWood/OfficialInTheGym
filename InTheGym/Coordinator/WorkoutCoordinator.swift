//
//  WorkoutCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

/// Child Coordinator to handle the flow when a workout is displayed
class WorkoutCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    var workout: WorkoutDelegate
    
    init(navigationController: UINavigationController, workout: WorkoutDelegate) {
        self.navigationController = navigationController
        self.workout = workout
    }
    
    func start() {
        let vc = DisplayWorkoutViewController.instantiate()
        vc.coordinator = self
        vc.selectedWorkout = workout
        vc.hidesBottomBarWhenPushed = true
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
extension WorkoutCoordinator {
    func showCircuit() {
        let vc = DisplayCircuitViewController.instantiate()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showCompletedPage() {
        let vc = WorkoutCompletedViewController.instantiate()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showUser(with user: Users) {
        let child = UserProfileCoordinator(navigationController: navigationController, user: user)
        childCoordinators.append(child)
        child.start()
    }
}


//MARK: - Navigation Delegate Method
extension WorkoutCoordinator: UINavigationControllerDelegate {
    
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
